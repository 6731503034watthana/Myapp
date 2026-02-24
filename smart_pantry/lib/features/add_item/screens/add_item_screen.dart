import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart'; // เพิ่มสำหรับรูปภาพ

=======
>>>>>>> 1ceab7ec31c293d7565f0c91b8a0db451b42a19e
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/food_category.dart';
import '../../../providers/category_provider.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});
<<<<<<< HEAD
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
=======
>>>>>>> 1ceab7ec31c293d7565f0c91b8a0db451b42a19e

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
<<<<<<< HEAD
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
=======
        child: Consumer<CategoryProvider>(
          builder: (context, catProvider, _) {
            final categories = catProvider.categories;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('➕ Add Item', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Select a category to get started', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Section: Select Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () => _showCreateCategoryDialog(context, catProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text('Create', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
>>>>>>> 1ceab7ec31c293d7565f0c91b8a0db451b42a19e
                          ),
                        ),
                      ],
                    ),
<<<<<<< HEAD
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
=======
                  ),
                  const SizedBox(height: 12),

                  // Category Grid
                  if (categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('📂', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('No categories yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Tap "Create" to add your first category', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return _CategoryTile(
                          category: cat,
                          onTap: () => context.push(AppRoutes.addItemForm, extra: cat),
                          onLongPress: () => _showDeleteDialog(context, catProvider, cat),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
>>>>>>> 1ceab7ec31c293d7565f0c91b8a0db451b42a19e
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  void _showCreateCategoryDialog(BuildContext context, CategoryProvider catProvider) {
    final nameController = TextEditingController();
    String selectedEmoji = FoodCategory.availableEmojis[0];
    Color selectedColor = FoodCategory.availableColors[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('➕ Create Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Vegetables',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Emoji picker
                const Text('Emoji', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FoodCategory.availableEmojis.map((emoji) {
                    final isSelected = emoji == selectedEmoji;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedEmoji = emoji),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color picker
                const Text('Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FoodCategory.availableColors.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                catProvider.addCategory(name, selectedEmoji, selectedColor);
                Navigator.pop(ctx);
              },
              child: const Text('Create', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CategoryProvider catProvider, FoodCategory cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${cat.label}"?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text('This will remove the category. Items using it will show as uncategorized.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              catProvider.deleteCategory(cat.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.expired)),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final FoodCategory category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CategoryTile({required this.category, required this.onTap, required this.onLongPress});

>>>>>>> 1ceab7ec31c293d7565f0c91b8a0db451b42a19e
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
<<<<<<< HEAD
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
=======
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [category.color, category.color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
>>>>>>> 1ceab7ec31c293d7565f0c91b8a0db451b42a19e
      ),
    );
  }
}
