// หน้า login

import 'package:flutter/material.dart';

// หน้า signup, home
import 'signup.dart';
import 'home.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart'; // ใช้ Google Fonts



void main() {
  runApp(const MyApp());
}


// -------------------------------------- ส่วน theme --------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      // ธีมทั้งapp
      theme: ThemeData( 

        // ใช้ Google Fonts - Prompt ภาษาไทยสวยๆ(ตัวมันอ้วนๆดี)
        fontFamily: GoogleFonts.prompt().fontFamily,

        // รูปแบบของ textformfield ทั้งหมดเลย
        inputDecorationTheme: InputDecorationTheme(
          filled: true, 
          fillColor: Colors.white, // พื้นหลังขาวเท่านั้น
          labelStyle: const TextStyle(color: Colors.grey), // สี label ปกติ
          floatingLabelStyle: const TextStyle(color: Color(0xFF4F6BFF)), // สี label ตอน focus
          hintStyle: const TextStyle(color: Colors.grey), // สี hint
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          
          // ขอบ
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide( color: Color.fromARGB(255, 220, 220, 220), width: 1.5),
          ),

          // ตอนไม่ focus
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide( color: Color.fromARGB(255, 220, 220, 220), width: 1.5),
          ),

          // ตอน focus
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4F6BFF), width: 2),
          ),
          
        ),

        useMaterial3: true, // ดีไซน์ของ Google (เหมือนสีอะไรมันจะนวลๆขึ้น)
      ),

      home: const LoginPage(), // ให้เปิดอันนี้เป็นหน้าแรก
      debugShowCheckedModeBanner: false, // ปิด banner debug มุมบนขวา
    );
  }
}
// -------------------------------------- ส่วน theme --------------------------------------







// สร้าง Stateful
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}


// --------------------------- ส่วน login ---------------------------
class _LoginPageState extends State<LoginPage> {
  
  final _formKey = GlobalKey<FormState>(); // เช็คความถูกต้อง ในที่นี้หมายถึงว่ามีข้อมูลมั้ย

  final usernameController = TextEditingController(); // อัพเดท username
  final passwordController = TextEditingController(); // อัพเดท password

  bool isLoading = false; // ไว้เปิดปิดปุ่ม login
  String errorMessage = ''; // ไว้แสดง error
  bool _obscurePassword = true; // ไวเปิดปิดลูกตา

  // เคลียร์ resource ก่อน widget ถูกทำลาย
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --------------------- ฟังก์ชัน logic login ---------------------
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) { // เช็คว่ามีข้อมูลในฟอมมั้ย (เรียกใช้ validate ของแต่ละ textformfield)
      
      setState(() { 
        isLoading = true; // ปิดปุ่ม
        errorMessage = ''; // เคลีย error
      }); 
      try {
        await Future.delayed(const Duration(milliseconds: 1500)); // ทำไว้เท่ๆ ให้มันดูมีอะไร

        final response = await http.post( // ขอ request
          Uri.parse('http://localhost:3000/login'), // จาก
          headers: {'Content-Type': 'application/json'}, // เป็น json
          body: jsonEncode({
            'username': usernameController.text,
            'password': passwordController.text,
          }), // แปลงข้อมูลเป็น json ก่อนส่ง
        );
        
        // login ได้
        if (response.statusCode == 200) {
         
          final responseData = jsonDecode(response.body); // แปลงข้อมูลจาก JSON เป็น object เก็บใน responseData
          final user = responseData['user']; // เอาแค่ Object user จาก response มาเก็บใน final user

          // mounted มันเหมือนเช็คว่ายังมีผู้ใช้อยู่ที่จอมั้ยถ้าไม่จะได้หยุด procress ในนี้ (ไม่แน่ใจ)
          if (!mounted) return;

          // note: ไปหน้า HomePage
            // user อันแรก คือชื่อ key ที่จะส่งไปให้หน้าอื่นๆใช้ข้อมูล
            // user อันรอง คือ final user ที่มี Object user อยู่ อย่างงนะ
          Navigator.pushReplacement( context,
            MaterialPageRoute( builder: (context) => HomePage(user: user)),
          );
          // pushReplacement = ไปหน้า HomePage แล้วล้างหน้านี้
        
        } else {
          final responseError = jsonDecode(response.body); // แปลงข้อมูลเหมือนกัน
          setState(() { errorMessage = responseError['error']; }); // เอาแค่ Object error
        }

      } catch (e) {
        setState(() { errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'; });
      
      } finally {
        setState(() { isLoading = false; }); // เปิดปุ่ม
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
                
                // --------------------- logo ---------------------
                const SizedBox(height: 56),
                Center(
                  child: Container(
                    height: 110,
                    width: 110,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),

                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4F6BFF),
                          Color(0xFF30D6B0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F6BFF).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                  ),
                ),
                
                const SizedBox(height: 26),


                // ------------------- ข้อความใต้ logo ------------------
                const Text('SC-PeopleHub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F6BFF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),


                // ------------------- ข้อความใต้ ข้อความใต้ logo อีกทีนึง ------------------
                Text('ยินดีต้อนรับ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),


                // ------------------ ขึ้น Error message (ถ้ามี) ------------------
                if (errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon( Icons.error_outline, color: Colors.red.shade700, size: 22 ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text( errorMessage, 
                              style: TextStyle( color: Colors.red.shade700,  fontSize: 14 ),
                          ),
                        ),
                      ],
                    ),
                  ),


                // ช่อง Username
                TextFormField(
                  controller: usernameController, // เรียกเพื่ออัพเดทข้อความที่เขียน
                  decoration: InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    hintText: 'กรอกชื่อผู้ใช้ของคุณ',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: const Color(0xFF4F6BFF).withOpacity(0.7),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    return null;
                  }, // ดักให้ใส่ชื่อด้วย
                ),
                const SizedBox(height: 20),


                // รหัส
                TextFormField(
                  controller: passwordController, // เรียกเพื่ออัพเดทข้อความที่เขียน
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    hintText: 'กรุกรอกรหัสผ่าน',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: const Color(0xFF4F6BFF).withOpacity(0.7),
                    ),

                    suffixIcon: Padding(
                      // ใส่ padding ขวาเดี๋ยวมันติดขอบไป
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                            icon: Icon( _obscurePassword ? 
                                  Icons.visibility_outlined // true
                                : Icons.visibility_off_outlined, // false
                            color: Colors.grey.shade600,
                          ),
                        onPressed: () { setState(() { _obscurePassword = !_obscurePassword; });}
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  obscureText: _obscurePassword, // ไว้ทำให้มันเป็นรูปแบบ รหัสผ่านตลอด (true,false)

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  }, // ดักให้ใส่รหัสผ่านด้วย
                ),
                const SizedBox(height: 35),


                // -------------- ปุ่ม Login --------------
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

                  // เช็ค isLoading เป็น true,false | false = เรียก _login
                  onPressed: isLoading ? null : _login,

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
                          Text( 'กำลังโหลด...',
                            style: TextStyle(fontSize:16, fontWeight: FontWeight.w600,color: Colors.white)),
                        ],
                      ),
                    )
                      
                    : // false = เปิดปุ่ม
                    const Text('เข้าสู่ระบบ', 
                      style: TextStyle(
                        fontSize:16, 
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                ),
                





                // --------------------- สมัครสมาชิกใหม่ ---------------------
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ยังไม่มีบัญชี?',style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    // GestureDetector = จับการเคลื่อนไหวมี ontapให้ใช้ (ไม่อยากใช้ textButton)
                    GestureDetector(
                      onTap: () {
                        // .push อันนี้มันเหมือนเอาหน้าอื่นมาทับเฉยๆ (เพราะมันเป็น stack)
                        Navigator.push(
                          context,
                          // https://youtu.be/A-OEPxImjMA?si=Wm2UUmX7vT6QNNpX
                          PageRouteBuilder(
                            pageBuilder:
                              (context, animation, secondaryAnimation) => const SignupPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // มาจากด้านขวา
                                const end = Offset.zero;
                                const curve = Curves.easeOutCubic; // ทำให้ดูเบาๆนุ่มๆ

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                          ),
                        );
                        
                      },
                       
                      child: const Text('ลงทะเบียนที่นี่',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F6BFF),
                          ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
