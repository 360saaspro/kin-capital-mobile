import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'send_amount_screen.dart';

class RecipientsScreen extends StatelessWidget {

  const RecipientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=maya'),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Good morning',
                            style: AppTheme.headingStyle(
                              fontSize: 18,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.notifications_outlined, color: AppColors.primaryTeal),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Who are we sending\nto?',
                    style: AppTheme.headingStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search name or @handle',
                        hintStyle: AppTheme.bodyStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Frequent Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Frequent', style: AppTheme.headingStyle(fontSize: 18)),
                          Text(
                            'SEE ALL',
                            style: AppTheme.bodyStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24),
                        children: [
                          _buildFrequentItem(context, 'Mom', 'https://i.pravatar.cc/150?u=mom'),
                          _buildFrequentItem(context, 'Sis', 'https://i.pravatar.cc/150?u=sis'),
                          _buildFrequentItem(context, 'Tunde', 'https://i.pravatar.cc/150?u=tunde'),
                          _buildFrequentItem(context, 'Marcus', 'https://i.pravatar.cc/150?u=marcus'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // All Contacts
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('All contacts', style: AppTheme.headingStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildContactGroup('A', [
                      _buildContactItem(context, 'Andre Anderson', '@dre_anderson', null),
                    ]),
                    _buildContactGroup('B', [
                      _buildContactItem(context, 'Brianna Brown', '+1 (876) 555-0123', 'https://i.pravatar.cc/150?u=brianna'),
                    ]),
                    _buildContactGroup('C', [
                      _buildContactItem(context, 'Chris Campbell', '+1 (876) 444-9876', 'https://i.pravatar.cc/150?u=chris'),
                    ]),
                    
                    // Promo Banner
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF001F1D), // Very dark teal
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send home for less',
                              style: AppTheme.headingStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'New 0% fee transfers to\nJamaica this weekend.',
                              style: AppTheme.bodyStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF80F0E6),
                                foregroundColor: AppColors.primaryTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('LEARN MORE'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 8,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('NEW RECIPIENT'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequentItem(BuildContext context, String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendAmountScreen(
              recipientName: name,
              avatarUrl: imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryTeal, width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: AppTheme.bodyStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactGroup(String letter, List<Widget> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(letter, style: AppTheme.bodyStyle(fontSize: 12, color: Colors.grey)),
        ),
        ...contacts,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, String name, String detail, String? imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendAmountScreen(
              recipientName: name,
              avatarUrl: imageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (imageUrl != null)
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl))
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.split(' ').map((e) => e[0]).join(''),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.bodyStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(detail, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              if (detail.contains('+1'))
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                   decoration: BoxDecoration(
                     color: Colors.grey[100],
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: const Text('JM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
