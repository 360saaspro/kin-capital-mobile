const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// You must have Google Application Default Credentials configured,
// or provide a serviceAccountKey.json path if running outside a GCP environment configured with ADC.
// To run: `node scripts/migrate_users_to_auth.js`
admin.initializeApp({
  projectId: 'kin-banking' // Update if different
});

const db = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD = 'Password123!';

async function migrateUsers() {
  console.log('Starting migration of users from Firestore to Firebase Auth...');

  const usersRef = db.collection('users');
  const snapshot = await usersRef.get();

  if (snapshot.empty) {
    console.log('No users found in Firestore.');
    return;
  }

  let migratedCount = 0;

  for (const doc of snapshot.docs) {
    const docId = doc.id;
    const userData = doc.data();

    // Skip if the docId is already a standard Firebase Auth UID (usually 28 chars)
    if (docId.length === 28 && !docId.startsWith('user_')) {
      console.log(`Skipping document ${docId} (already looks like a standard UID).`);
      continue;
    }

    const email = userData.email;
    if (!email) {
      console.log(`Skipping document ${docId} (no email found in document data).`);
      continue;
    }

    console.log(`Processing user with ID: ${docId}, email: ${email}`);

    try {
      let authUser;
      // Check if user already exists in Auth
      try {
        authUser = await auth.getUserByEmail(email);
        console.log(`User ${email} already exists in Auth. UID: ${authUser.uid}`);
      } catch (authErr) {
        if (authErr.code === 'auth/user-not-found') {
          // Create the user in Firebase Auth
          authUser = await auth.createUser({
            email: email,
            password: DEFAULT_PASSWORD,
            displayName: userData.fullName || 'Kin User',
          });
          console.log(`Created new Auth user for ${email}. UID: ${authUser.uid}`);
        } else {
          throw authErr;
        }
      }

      const uid = authUser.uid;

      // Prepare the updated user data
      const newUserData = {
        ...userData,
        uid: uid,
        email: email
      };

      // Create the new document with the UID
      await usersRef.doc(uid).set(newUserData);
      console.log(`Created new Firestore document with UID: ${uid}`);

      // Delete the old document
      await usersRef.doc(docId).delete();
      console.log(`Deleted old Firestore document with ID: ${docId}`);

      migratedCount++;
    } catch (error) {
      console.error(`Error migrating user ${docId}:`, error);
    }
  }

  console.log(`Migration complete. Successfully migrated ${migratedCount} users.`);
}

migrateUsers().catch(console.error);
