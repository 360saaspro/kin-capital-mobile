const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp({
  projectId: 'kin-banking' // Update if different
});

const db = admin.firestore();

async function migrateTransactions() {
  console.log('Starting migration of transactions...');

  const txRef = db.collection('transactions');
  const snapshot = await txRef.get();

  if (snapshot.empty) {
    console.log('No transactions found in Firestore.');
    return;
  }

  let migratedCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (!data.currency) {
      await doc.ref.update({ currency: 'JMD' });
      migratedCount++;
      console.log(`Updated transaction ${doc.id} to JMD.`);
    }
  }

  console.log(`Migration complete. Migrated ${migratedCount} transactions.`);
}

migrateTransactions().catch(console.error);
