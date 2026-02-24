import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart'; // เพิ่มสำหรับรูปภาพ

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/food_category.dart';
import '../../../models/food_item.dart';
import '../../../providers/food_items_provider.dart';
import '../../../services/mock_data_service.dart';
import '../widgets/category_grid.dart';
import '../widgets/food_quick_select.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  FoodCategory? _selectedCategory;
  final TextEditingController _customCategoryController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedEmoji = '📦';
  String _selectedUnit = 'ชิ้น'; // ค่าเริ่มต้นหน่วย
  final List<String> _units = [
    'ชิ้น',
    'กิโลกรัม',
    'กรัม',
    'ลิตร',
    'ขวด',
    'แพ็ค',
  ];

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  final _quickFoods = MockDataService.getQuickSelectFoods();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _customCategoryController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลือกรูปภาพ (ถ่ายรูป หรือ อัปโหลด)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _onCategorySelected(FoodCategory category) {
    setState(() {
      _selectedCategory = category;
      _customCategoryController.clear(); // ล้างช่องกรอกเองถ้าเลือกจากระบบ
    });
  }

  void _onFoodSelected(Map<String, dynamic> food) {
    setState(() {
      _nameController.text = food['name'] as String;
      _selectedEmoji = food['emoji'] as String;
      _selectedCategory = food['category'] as FoodCategory;
    });
  }

  void _changeDate(int days) =>
      setState(() => _expiryDate = _expiryDate.add(Duration(days: days)));

  void _addItem() {
    final itemName = _nameController.text.trim();
    final customCatName = _customCategoryController.text.trim();

    // ตรวจสอบข้อมูลก่อน Add
    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่อวัตถุดิบ'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_selectedCategory == null && customCatName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกหรือสร้าง Category'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // สร้าง Category ใหม่กรณีที่ผู้ใช้พิมพ์เข้ามาเอง
    final categoryToUse = customCatName.isNotEmpty
        ? FoodCategory(
            id: const Uuid().v4(),
            name: customCatName,
            icon: '🏷️',
            color: Colors.blue,
          )
        : _selectedCategory!;

    // หมายเหตุ: ตรงนี้อาจต้องไปแก้ Model FoodItem ของคุณให้รับรูปภาพ (imagePath), quantity และ unit ด้วยนะครับ
    final newItem = FoodItem(
      id: const Uuid().v4(), 
      name: itemName, 
      category: categoryToUse, 
      emoji: _selectedEmoji, 
      purchaseDate: DateTime.now(), 
      expiryDate: _expiryDate,
      quantity: double.tryParse(_quantityController.text) ?? 1.0, // ดึงค่าจำนวน
      unit: _selectedUnit,                                        // ดึงค่าหน่วย
      imagePath: _imageFile?.path,                                // ดึงที่อยู่ไฟล์รูปภาพ
    );

    context.read<FoodItemsProvider>().addItem(newItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ เพิ่ม $itemName ลงตู้เย็นแล้ว!'),
        backgroundColor: AppColors.safe,
      ),
    );

    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '➕ Add Item',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ส่วนของ Category
              _sectionTitle('1. เลือกหรือสร้าง Category'),
              const SizedBox(height: 8),
              CategoryGrid(
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customCategoryController,
                decoration: InputDecoration(
                  hintText: 'หรือสร้าง Category ใหม่เอง...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.add_circle_outline),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty) setState(() => _selectedCategory = null);
                },
              ),
              const SizedBox(height: 24),

              // 2. ข้อมูลวัตถุดิบ (ชื่อและจำนวน)
              _sectionTitle('2. ข้อมูลวัตถุดิบ'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อวัตถุดิบ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'จำนวน',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _units
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedUnit = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. รูปภาพ (ถ่าย / อัปโหลด)
              _sectionTitle('3. รูปภาพวัตถุดิบ'),
              const SizedBox(height: 8),
              if (_imageFile != null) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('ถ่ายรูป'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. วันหมดอายุ
              _sectionTitle('4. วันหมดอายุ'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Expiry Date',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_expiryDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _DateArrowButton(
                          icon: Icons.chevron_left,
                          onTap: () => _changeDate(-1),
                        ),
                        const SizedBox(width: 8),
                        _DateArrowButton(
                          icon: Icons.chevron_right,
                          onTap: () => _changeDate(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ปุ่มบันทึก
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '✅ Add to Pantry',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}

class _DateArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DateArrowButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }
}
