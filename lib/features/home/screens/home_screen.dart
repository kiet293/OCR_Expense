import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/receipt_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../scan/screens/camera_scan_screen.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/recent_receipt_item.dart';
import '../widgets/scan_action_banner.dart';

/// Màn hình Trang chủ (Dashboard) chính của BillLens
/// Kết nối động với SQLite qua ReceiptController
class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToScan;
  final VoidCallback? onNavigateToExpenses;

  const HomeScreen({
    super.key,
    this.onNavigateToScan,
    this.onNavigateToExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ReceiptController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final receipts = controller.receipts;
            final double monthTotal = controller.monthTotal;
            final double weekTotal = controller.weekTotal;
            final int receiptCount = receipts.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header chào mừng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.document_scanner_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {},
                          tooltip: 'Thông báo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Thẻ số liệu thống kê nhanh (Quick Stats từ SQLite)
                  Row(
                    children: [
                      Expanded(
                        child: QuickStatCard(
                          title: 'Chi tiêu tháng này',
                          amount: AppFormatter.formatCurrency(monthTotal),
                          icon: Icons.calendar_month_rounded,
                          iconColor: AppColors.primary,
                          subtitle: 'Tháng ${DateTime.now().month}/${DateTime.now().year}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickStatCard(
                          title: 'Chi tiêu tuần này',
                          amount: AppFormatter.formatCurrency(weekTotal),
                          icon: Icons.trending_up_rounded,
                          iconColor: AppColors.secondary,
                          subtitle: '$receiptCount hóa đơn',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Banner hành động Quét hóa đơn (Scan Action Banner)
                  ScanActionBanner(
                    onScanPressed: () {
                      if (onNavigateToScan != null) {
                        onNavigateToScan!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraScanScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tiêu đề phần Hóa đơn gần đây
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hóa đơn gần đây',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (onNavigateToExpenses != null) {
                            onNavigateToExpenses!();
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Danh sách hóa đơn thực tế từ SQLite (lấy tối đa 5 hóa đơn mới nhất)
                  if (controller.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (receipts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'Chưa có hóa đơn nào',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: receipts.length > 5 ? 5 : receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = receipts[index];
                        return RecentReceiptItem(
                          receipt: receipt,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Hóa đơn: ${receipt.merchant} (${AppFormatter.formatCurrency(receipt.total)})',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
