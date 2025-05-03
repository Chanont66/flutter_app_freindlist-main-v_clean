// หน้าสมัคร

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';




// สร้าง Stateful
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}


// --------------------------- ส่วนสมัคร ---------------------------
class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>(); // เช็คความถูกต้อง ในที่นี้หมายถึงว่ามีข้อมูลมั้ย

  // เอาไว้อัพเดตข้อมูลทุกครั้งที่พิมพ์ข้อมูล
  final usernameController = TextEditingController(); // ชื่อผู้ใช้
  final fnameController = TextEditingController(); // ชื่อจริง
  final lnameController = TextEditingController(); // นามสกุล

  final phoneController = TextEditingController(); // เบอร์โทร

  final passwordController = TextEditingController(); // รหัสผ่านช่องแรก
  final confirmPasswordController = TextEditingController(); // ยืนยันรหัส

  bool isLoading = false; // เปิดปิดปุ่มลงทะเบียน
  String errorMessage = ''; // ขึ้น error

  // เคลียร์ข้อมูล ก่อน widget ถูกทำลาย
  @override
  void dispose() {
    usernameController.dispose();
    fnameController.dispose();
    lnameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  // --------------------- ฟังก์ชัน logic สมัคร ---------------------
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) { // เช็คว่ามีข้อมูลในฟอมมั้ย (เรียกใช้ validate ของแต่ละ textformfield)

      setState(() { 
        isLoading = true; // ปิดปุ่ม
        errorMessage = ''; // เคลีย error
      }); 

      try {
        final response = await http.post( // ขอ request
          Uri.parse('http://localhost:3000/users'), // จาก
          headers: {'Content-Type': 'application/json'}, // เป็น json
          body: jsonEncode({
            'username': usernameController.text,
            'fname': fnameController.text,
            'lname': lnameController.text,
            'phone': phoneController.text,
            'password': passwordController.text, }), // แปลงข้อมูลเป็น json ก่อนส่ง
        );

        // ถ้า OK
        if (response.statusCode == 200) {
          
          // mounted มันเหมือนเช็คว่ายังมีผู้ใช้อยู่ที่จอมั้ยถ้าไม่จะได้หยุด procress ในนี้ (ไม่แน่ใจ)
          if (!mounted) return;
          
          // แจ้งเตือน - https://youtu.be/zpO6n_oZWw0?si=RyFUeCuqko4MSawN
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar( 
              backgroundColor: Colors.green,
              content: Row(
                children: [
                  Icon(Icons.check, color: Colors.white,),
                  SizedBox(width: 8),
                  Text('ลงทะเบียนสำเร็จ', style: TextStyle(color: Colors.white),)
                ]
              ),
            ),
          );

          Navigator.pop(context); // กลับไปหน้าล็อกอิน (ปิดหน้าปัจจุบัน)

        } else { // ?? ดู null ด้านซ้าย ถ้าใช่ ก็ขึ้นซ้าย ถ้าไม่ใช่ก็ขึ้นขวา
          final responseError = jsonDecode(response.body); // แปลงข้อมูลจาก JSON เป็น object
          setState(() { errorMessage = responseError['error']; }); // เอาแค่ Object error
        }

      } catch (e) {
        setState(() { errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'; });

      } finally {
        setState(() {isLoading = false; }); // ทำเสร็จปรับเป็น false เพื่อเปลี่ยนรูปแบบปุ่ม (ปิดปุ่ม)
      }
    }
  }




  // ส่วน UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        // เลื่อนได้
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                
                // ------------------ ลูกศรกลับlogin ------------------
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                  ),
                ),
                const SizedBox(height: 16),

                
                // ------------------ icon รูปคน+ ------------------
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.indigo.shade50,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon( Icons.person_add_outlined, size: 48, color: Colors.indigo.shade700 ) // รูปคน+
                ),
                const SizedBox(height: 24),


                // ------------------ ข้ิความ ------------------
                const Text( 'สร้างบัญชีใหม่',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                // ------------------ ข้อความอีกอันข้างล่าง ------------------
                const SizedBox(height: 8),
                Text( 'กรุณากรอกข้อมูลเพื่อลงทะเบียน',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                


                // ------------------ ข้อมูลส่วนตัว ------------------
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      
                    // หัวข้อใส่ข้อมูลส่วน
                    Text('ข้อมูลส่วนตัว',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                      
                    // ชื่อผู้ใช้
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อผู้ใช้',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่อผู้ใช้';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    
                    // Row สำหรับชื่อ + นามสกุล
                    Row(
                      children: [
                        // ชื่อจริง
                        Expanded(
                          child: TextFormField(
                            controller: fnameController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อจริง',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกชื่อจริง';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
  
                        // นามสกุล
                        Expanded(
                          child: TextFormField(
                            controller: lnameController,
                            decoration: const InputDecoration(
                              labelText: 'นามสกุล',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกนามสกุล';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                      

                    // เบอร์โทรศัพท์
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรศัพท์',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '0899999999',
                      ),
                      maxLength: 10, // มากสุด 10 ตัว
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly, // ใส่ได้แค่เลข
                      ],
                      validator: (value) { 
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกเบอร์โทรศัพท์';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                
                
                
                

                // ------------------ ความปลอดภัย ------------------
                const SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( 'ความปลอดภัย',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                      
                      
                    // รหัสผ่าน
                    TextFormField(
                      controller: passwordController, // อัพเดทรหัสผ่าน
                      decoration: const InputDecoration(
                        labelText: 'รหัสผ่าน',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกรหัสผ่าน';
                        }
                        if (value.length < 6) {
                          return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                        }
                        return null;
                      },
                      obscureText: true, // รูปแบบรหัสผ่าน
                    ),
                    const SizedBox(height: 16),
                    

                    // ยืนยันรหัสผ่าน
                    TextFormField(
                      controller: confirmPasswordController, // อัพเดทยืนยันรหัสผ่าน
                      decoration: const InputDecoration(
                        labelText: 'ยืนยันรหัสผ่าน',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณายืนยันรหัสผ่าน';
                        }
                        if (value != passwordController.text) {
                          return 'รหัสผ่านไม่ตรงกัน';
                        }
                        return null;
                      },
                      obscureText: true, // รูปแบบรหัสผ่าน
                    ),
                  ],
                ),
                
                


                // ------------------ ขึ้น Error message (ถ้ามี) ------------------
                if (errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text( errorMessage,
                            style: TextStyle(color: Colors.red.shade700 ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                


                // ปุ่มลงทะเบียน
                const SizedBox(height: 35),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: const Color(0xFF4F6BFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blueAccent,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                      // เช็ค isLoading เป็น true,false | false = เรียก _register
                  onPressed: isLoading ? null : _register,
                  
                  child: isLoading ?
                    // true = กำลังโหลด
                    const SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // ทำให้พอดีกับ Row
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator( // วงกลมโหลดๆ หมุนๆ
                              strokeWidth: 2.5, // ความหนา
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('กำลังโหลด...',
                            style:TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.white),
                          ),
                        ],
                      ),
                    )
                            
                    : // false = เปิดปุ่ม
                    const Text( 'ลงทะเบียน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                ),
                const SizedBox(height: 30),
              
              ],
            ),
          ),
        ),
      ),
    );
  }

  
}