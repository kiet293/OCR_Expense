import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/receipt_model.dart';
import '../../scan/screens/camera_scan_screen.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/recent_receipt_item.dart';
import '../widgets/scan_action_banner.dart';

/// Màn hình Trang chủ (Dashboard) chính của BillLens
class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToScan;
  final VoidCallback? onNavigateToExpenses;

  const HomeScreen({
    super.key,
    this.onNavigateToScan,
    this.onNavigateToExpenses,
  });

  /// Dữ liệu mẫu ban đầu theo đúng đặc tả yêu cầu (Mục 23: Test Data)
  static final List<ReceiptModel> _sampleReceipts = [
    ReceiptModel(
      id: 1,
      merchant: 'WINMART',
      total: 150000,
      date: DateTime(2026, 10, 1),
      category: 'Thực phẩm',
      imagePath: '',
      rawText: 'WINMART\n01/10/2026\nSua tuoi TH True Milk 45.000\nBanh mi 20.000\nNuoc 15.000\nTOTAL 150.000 VND',
      note: 'Mua đồ ăn sáng và nước uống',
      createdAt: DateTime(2026, 10, 1, 8, 30),
    ),
    ReceiptModel(
      id: 2,
      merchant: 'CIRCLE K',
      total: 85000,
      date: DateTime(2026, 9, 30),
      category: 'Thực phẩm',
      imagePath: '',
      rawText: 'CIRCLE K\n30/09/2026\nSnack & Cafe\nTOTAL: 85.000 đ',
      note: 'Cà phê sáng',
      createdAt: DateTime(2026, 9, 30, 9, 15),
    ),
    ReceiptModel(
      id: 3,
      merchant: 'FPT SHOP',
      total: 1200000,
      date: DateTime(2026, 9, 28),
      category: 'Thiết bị',
      imagePath: '',
      rawText: 'FPT SHOP\n28/09/2026\nChuot khong day & Ban phim co\nTOTAL: 1.200.000 VND',
      note: 'Phụ kiện phục vụ làm đồ án',
      createdAt: DateTime(2026, 9, 28, 14, 0),
    ),
    ReceiptModel(
      id: 4,
      merchant: 'BOOKSTORE',
      total: 250000,
      date: DateTime(2026, 9, 27),
      category: 'Nghiên cứu',
      imagePath: '',
      rawText: 'BOOKSTORE\n27/09/2026\nGiao trinh Flutter & AI on-device\nTOTAL: 250.000 VND',
      note: 'Sách chuyên khảo sinh viên',
      createdAt: DateTime(2026, 9, 27, 16, 45),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Tính toán nhanh số liệu mẫu
    final double monthTotal = _sampleReceipts.fold(0, (sum, r) => sum + r.total);
    final double weekTotal = _sampleReceipts.take(2).fold(0, (sum, r) => sum + r.total);
    final int receiptCount = _sampleReceipts.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Thẻ số liệu thống kê nhanh (Quick Stats)
              Row(
                children: [
                  Expanded(
                    child: QuickStatCard(
                      title: 'Chi tiêu tháng này',
                      amount: AppFormatter.formatCurrency(monthTotal),
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.primary,
                      subtitle: 'Tháng 10/2026',
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

              // Danh sách hóa đơn gần đây
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sampleReceipts.length,
                itemBuilder: (context, index) {
                  final receipt = _sampleReceipts[index];
                  return RecentReceiptItem(
                    receipt: receipt,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hóa đơn: ${receipt.merchant} (${AppFormatter.formatCurrency(receipt.total)})'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
