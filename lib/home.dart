import 'package:flutter/material.dart';

import 'main.dart';
import 'profile.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'folder_management.dart';
import 'folder_detail.dart';



// สร้าง Stateful
class HomePage extends StatefulWidget {
  final dynamic user; // ไม่ต้องดูชนิดข้อมูล
  const HomePage({super.key, required this.user});
  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  
  List folders = []; // ประกาศ list ไว้เก็บข้อมูลโฟลเดอร์ (เลยไม่ต้องใช้ widget.folders)
  bool isLoading = true; // เปิดวงกลม loading ตลอด 
  final String apiBaseUrl = 'http://localhost:3000';

  // Animation controllers
  late AnimationController _animationController; // เก็บ object ของ animation ทั้งหมดเลยย
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  
  // เคลียร์ animation
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  // ---------------------------- initState = เรียกครั้งเดียว ----------------------------
  @override
  void initState() {
    super.initState();

    // AnimationController
    // คือเหมือนคลาสที่มี ฟังก์ชั่น ของ animationต่างๆ ก็จะมี forward, reverse, stop, reset ประมาณนี้
    _animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 600),
    );
    // เหมือนสร้าง object จาก AnimationController แล้วเก็บในตัวแปรไว้เรียกใช้อีกที
    

    // https://youtu.be/hMFoklQ6oHo?si=lat5gRTAjlYEFW4X
    // fade animation
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease,
      ),
    );
      
    // scale animation
    _scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
      parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    // ------------------------------------------------

    _animationController.forward(); // เริ่ม animation ตอน login เข้ามา
    fetchFolders(); // เรียกข้อมูล folder (isLoading หลังfetchข้อมูล ก็จะเป็น false ตลอดเพราะโหลดข้อมูลเสร็จแล้ว)
  }

  




  // ----------------------- ฟังก์ชันสำหรับดึงข้อมูล folder -----------------------
  Future<void> fetchFolders() async {
    try {
      final response = await http.get( // ขอ request

        // จาก api เอาข้อมูลfolder จาก id ของ user ที่ได้จาก statefu
        Uri.parse('$apiBaseUrl/folders/user/${widget.user['id']}'), 
        headers: {'Content-Type': 'application/json'}, // เป็น json
      );
      
      // ถ้า OK
      if (response.statusCode == 200) {
        
        final data = jsonDecode(response.body); // แปลงข้อมูลจาก JSON เป็น object เก็บใน data
        
        // แปลงข้อมูลใน object data เป็น list ไปเก็บใน folders
        setState(() {
          if (data['folders'] is List) {
            folders = List.from(data['folders']); // แปลงข้อมูลใน data เป็น list ไปเก็บใน folders
          } else {
            folders = []; // folders เป็นลิสต์ว่าง
          }
          isLoading = false;
        });
      
      } else {
        setState(() {
          folders = [];
          isLoading = false;
        });
      }
    
    } catch (e) {
      setState(() {
        folders = [];
        isLoading = false;
      });
    }
  } // หลังจาก fetchFolders เสร็จแล้ว isLoading จะเป็น false ตลอดไปปปปป = ไม่ขึ้นโหลดอีกแล้ว




  // ----------------------------------- logout -----------------------------------
  Future<void> _showLogoutDialog() async {
    await showDialog( context: context, builder: (context) => AlertDialog(

    title: const Text('ออกจากระบบ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?',style: TextStyle(fontSize: 16)),
        
      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context), // ปิด Dialog
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 3,top: 3,left: 10,right: 10),
            backgroundColor: Colors.transparent, // โปร่งใส
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),

          child: const Text('ยกเลิก',
            style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),
          ),
        ),


        TextButton(
          onPressed: () {
            Navigator.pop(context); // ปิด Dialog
            performLogout(); // เรียกฟังก์ชันlogout
          },

          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 3,top: 3,left: 10,right: 10),
            backgroundColor: const Color(0xFF4F6BFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          
          child: const Text('ออกจากระบบ',
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 16),
          ),
        ),

      ],
    ));
  }
  
  
  // --------- ฟังก์ชันlogout + animation เฟี้ยวๆ ---------
  void performLogout() {
    // เล่น animation(แบบ reverse) ก่อนแล้วlogout
    _animationController.reverse().then((_) {
      // pushReplacement = ไปหน้า login แล้วล้างหน้านี้
      Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }





  // ส่วน UI
  @override
  Widget build(BuildContext context) {

    // คำนวณขนาดหน้าจอเพื่อปรับ UI
    final screenWidth = MediaQuery.of(context).size.width; // ความกว้างจอ (หน่วย px)
    final isSmallScreen = screenWidth < 380; // ดูขนาดจอ (ถ้าน้อยกว่า 360px เป็น true)
    

    return Scaffold(
      backgroundColor: Colors.white,
      
      // ----------------------------------- ส่วน appBar -----------------------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          
          decoration: BoxDecoration(
            color: const Color(0xFF6378FF),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // สีดำโปร่งใส
                spreadRadius: 1, // การกระจาย
                blurRadius: 8, // ความเบลอ
                offset: const Offset(0, 2.5), // ขยับไปด้านล่าง
              ),
            ],
          ),

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  
                  // ----------- icon logo -----------
                  Container(
                    height: 36,
                    width: 36, 
                    decoration: BoxDecoration(
                      color: Colors.white, // พื้นหลังขาว
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // สีดำโปร่งใส
                          blurRadius: 4, // ความเบลอ
                        )
                      ]
                    ),
                    child: const Center(
                      child: Icon( Icons.people_alt_rounded,  color: Color(0xFF4F6BFF),  size: 20,
                      ),
                    ),
                  ),
                                    
                  // ---- ชื่อโปรเจค ----
                  const SizedBox(width: 10),
                  const Text( 'SC-PeopleHub',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  
                  
                  
                  // ----------- ปุ่มProfile -----------
                  const Spacer(), // เว้นช่องว่างแบบ auto
                  InkWell( // แตะได้
                    onTap: () {
                      Navigator.push(context,
                        // ส่ง key user โดยข้อมูลมาจาก widget.user ที่ได้จากหน้า login
                        MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)), 
                      ).then((_) { fetchFolders(); });
                    },

                    child: Container(
                      // เช็คขนาดจอ แล้วปรับสเกลpadding
                      padding: EdgeInsets.symmetric( horizontal: isSmallScreen ? 8 : 12, vertical: 6 ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      
                      child: Row(
                        children: [
                          // กลมๆ ครอบชื่อ ที่เอาแค่ตัวอักษรแรก ก็พอมั้ง (จะขึ้นแค่นี้ถ้าจอเล็ก)
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Text( widget.user['fname'][0].toUpperCase(), // +ทำเป็นตัวพิมใหญ่
                              style: const TextStyle(
                                color: Color(0xFF4F6BFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          
                          // ถ้าจอใหญ่ ให้เพิ่มแสดงชื่อเต็ม (คงไม่ได้ใช้มั้ง...)
                          // if (!isSmallScreen) ...[
                          //   const SizedBox(width: 8),
                          //   Text( widget.user['fname'],
                          //     style: const TextStyle(
                          //       color: Colors.white,
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 14,
                          //     ),
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ),
                  
                  
                  
                  // ----------- Logout button -----------
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showLogoutDialog(), // เรียก Dialog ขึ้นมา
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.logout_rounded,color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ----------------------------------- ส่วน appBar -----------------------------------



      // ----------------------------------- ส่วน body -----------------------------------
      // ให้เล่น animation เวลา login,logout ที่เอา fade ผสมกับ scale
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },

        // ใช้ stack เพราะปุ่มไปหน้า folder ต้องอยู่บน _buildFoldersSection
        child: Stack(
          children: [

            // ----------------- จัดเนื้อหาหลักในหน้านี้ (อยู่ด้านล่างของ stack) -----------------
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          _buildGreetingCard(context), // สร้าง widget สวัสดี
                          const SizedBox(height: 24), 

                          _buildFoldersSection(context, isSmallScreen), // ด้านล่างทั้งหมดที่เหลือ
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            

            // ----------------- ปุ่ม +เพิ่มโฟลเดอร์ (อยู่ด้านบนของ stack) -----------------
            Positioned( // positioned = ไว้ปรับตําแหน่ง widget
              bottom: 20, right: 20,
              child: Container(
                height: 56, width: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6378FF),
                      Color(0xFF95A8FF),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F6BFF).withOpacity(0.35), // สีใส
                      blurRadius: 8, // ความเบลอ
                      spreadRadius: 1, // ความกระจาย
                      offset: const Offset(0, 3), // ขยับเงา
                    ),
                  ],
                ),

                // ปุ่มกลมๆ ไปหน้าเพิ่มโฟลเดอร์อีกอันนึง
                child: InkWell( // ทำให้กดได้
                  onTap: () {
                    Navigator.push( context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => FolderPage(user: widget.user),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0); // มาจากด้านล่าง
                          const end = Offset.zero; // ไปบน
                          const curve = Curves.ease; // ทำให้ดูเบาๆนุ่มๆ

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition( 
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(seconds: 1),
                      ),
                    ).then((_) { fetchFolders(); }); // อัพเดทข้อมูล
                  },
                  child: const Icon( Icons.add_rounded,color: Colors.white,size: 28 ),
                ),
              ),
            ),
            
          ],
        ),
      ),


    );
  }





  // ------------------------------ กล่องต้อนรับ สวัสดี ------------------------------
  Widget _buildGreetingCard(BuildContext context) {
  
    return Container(
        
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6479FF),  // สีฟ้าสว่างขึ้น
              Color(0xFF95A8FF),  // สีม่วงอ่อนให้เข้ากับ theme
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F6BFF).withOpacity(0.2), // สีใส
              blurRadius: 12, // ความเบลอ
              offset: const Offset(0, 6), // ขยับเงา
              spreadRadius: 0, // ความกระจาย
            ),
          ],
        ),

        child: Stack( // ใช้ stack ไว้ให้ widget อยู่ด้านบนของกล่อง
          children: [
            
            // ฟองกลมๆ อันขวา
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle,),
              ),
            ),

            // ฟองกลมๆเล็ก อันขวา
            Positioned(
              right: 80,
              top: 10,
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle,),
              ),
            ),

            // ฟองกลมๆ อันซ้าย
            Positioned(
              left: 30,
              bottom: -15,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1),shape: BoxShape.circle,),
              ),
            ),
            
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  
                  // ------ ทำรูปโปรไฟล์จำลอง ------
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Text(
                        widget.user['fname'][0].toUpperCase(), // +ทำเป็นตัวพิมพ์ใหญ่
                        style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Color(0xFF4F6BFF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  

                  // ------- Welcome text กับ ชื่อ -------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // เริ่มจากด้านซ้าย
                    children: [

                      const Text('สวัสดี',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                        
                      const SizedBox(height: 4),
                      Text('${widget.user['fname']} ${widget.user['lname']}', // ชื่อ + นามสกุล
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.alternate_email,size: 12,color: Colors.white70,),
                          const SizedBox(width: 4),
                          Text( widget.user['username'], // @ ชื่อผู้ใช้
                            style: const TextStyle(fontSize: 12,color: Colors.white70,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }




  // --------------- สร้างแถว icon + โฟลเดอร์ของฉัน + ปุ่มเฟือง ---------------
  Widget _buildFoldersSection(BuildContext context, bool isSmallScreen) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          
        // แถวรวม (icon,โฟลเดอร์ของฉัน + ปุ่มเฟือง)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              
            // -------------- โฟลเดอร์ของฉัน --------------
            Row(
              children: [  
                Container( // icon
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F6BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_rounded, color: Color(0xFF4F6BFF),size: 20 ),
                ),
                const SizedBox(width: 8),
                  
                Text('โฟลเดอร์ของฉัน',
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.grey.shade800),
                ),
              ],
            ),

            // -------------- ปุ่มจัดการ --------------
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push( context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => FolderPage(user: widget.user),
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
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ).then((_) { fetchFolders(); }); // อัพเดทข้อมูลใหม่
              },
                
              icon: const Icon( Icons.settings, size: 16, color: Color(0xFF4F6BFF) ),
              label: const Text( 'จัดการ',
                style: TextStyle(color: Color(0xFF4F6BFF),fontWeight: FontWeight.w500,fontSize: 13),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4F6BFF),
                side: const BorderSide(color: Color(0xFF4F6BFF)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: const Size(10, 30),
              ),
            ),

          ],
        ),
          const SizedBox(height: 16),
          

          // แสดง grid folder (ถ้ามีนะ true/flase)
          isLoading ?
            // true (ถ้ายัง true จะขึ้น loading)
            const Center(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator( // วงกลมโหลดๆ หมุนๆ
                    strokeWidth: 3, // ความหนา
                    color: Color(0xFF4F6BFF),
                  ),
                ),
              ),
            )
          
       : // false (false แล้ว = เช็คต่อว่ามี folder มั้ย)
          // .isEmpty ? true : false (ถ้าไม่มีเรียก _buildEmptyFolderState, ถ้ามีเรียก _buildFolderGrid )
          folders.isEmpty ? _buildEmptyFolderState(context) : _buildFolderGrid(context, isSmallScreen),
      ],
    );
  }


  // --------------------- ถ้ามีข้อมูลให้สร้าง grid ---------------------
  Widget _buildFolderGrid(BuildContext context, bool isSmallScreen) {
    
    // ปรับขนาด grid ตามขนาดหน้าจอ
    final crossAxisCount = isSmallScreen ? 2 : 4; // (true = 2, false = 4)

    // https://youtu.be/xfcKuJzFQWg?si=I-ug89bJ4w6A1fPA - วิธีใช้ GridView
    return GridView.builder(
      
      shrinkWrap: true, // มันเหมือนทำให้ GridView ไม่ขยายขนาดเกิน card ที่จะมี
      
      // ตั้งค่ารูปแบบ grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // มีกี่ column แล้วแต่ขนาดจอที่ได้ (2,4)
        mainAxisSpacing: 12, // ระยะห่างระหว่าง column (px)
        crossAxisSpacing: 12, // ระยะห่างระหว่าง row (px)
        childAspectRatio: 1, // ขนาดของ child
      ),

      itemCount: folders.length, // จํานวน folder (ที่ได้จาก API)
      
      itemBuilder: (context, index) {
        
        // เก็บ folder ตาม index ที่ได้จาก API
        final folder = folders[index]; 
          
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          color: const Color(0xFFF8F9FF),

          // -------------- คลิก card --------------
          child: InkWell( // InkWell ทำให้กดได้
            onTap: () {
              Navigator.push( context,
                MaterialPageRoute(
                  // ไปหน้า FolderDetail บวกส่งข้อมูล user และ folder ที่กดเลือก
                  builder: (context) => FolderDetailPage( user: widget.user, folder: folder ),
                ),
              ).then((_) { fetchFolders(); }); // ดึงข้อมูลใหม่หลังสร้าง folderใหม่
            },
              
            // -------------- รายละเอียดใน card --------------
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // --------- icon ---------
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6378FF).withOpacity(0.15), // ปรับโปร่งใส
                    shape: BoxShape.circle, // วงกลมหลังicon
                  ),
                  child: const Icon( Icons.folder_rounded, size: 32,color: Color(0xFF4F6BFF) ),
                ),
                const SizedBox(height: 10),
                  
                 // --------- ชื่อ folder --------- 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text( folder['name'],
                    style: const TextStyle( fontSize: 14,fontWeight: FontWeight.bold ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // ให้เขียนแค่ 1 บรรทัด 
                    overflow: TextOverflow.ellipsis, // ถ้าเกิน 1 บรรทัดจะขึ้นเป็น test...
                  ),
                ),
                  
                // --------- detail ---------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text( folder['detail']?.toString() ?? '', // ถ้าไม่มี detail ให้ขึ้นเป็นว่างๆ
                    style: TextStyle( fontSize: 11, color: Colors.grey.shade600 ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // ให้เขียนแค่ 1 บรรทัด 
                    overflow: TextOverflow.ellipsis, // ถ้าเกิน 1 บรรทัดจะขึ้นเป็น test...
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  // -------------------- ถ้าไม่มีข้อมูล เลยให้ขึ้นข้อความกับปุ่ม --------------------
  Widget _buildEmptyFolderState(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          
          // -------------- ขึ้นข้อความ ---------------
          const SizedBox(height: 20),
          Container(
            height: 80,
            width: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_off_outlined, size: 36, color: Colors.grey.shade400),
          ),

          Text('ยังไม่มีโฟลเดอร์',
            style: TextStyle( fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey.shade700 )),
          const SizedBox(height: 8),
          
          Text('คลิกปุ่ม "สร้างโฟลเดอร์" เพื่อเริ่มต้นใช้งาน',
            style: TextStyle( fontSize: 14,color: Colors.grey.shade500 )),
          const SizedBox(height: 20),


          // ปุ่มสร้าง folder
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0, // ไม่มีเงา
              backgroundColor: const Color(0xFF4F6BFF), // ฟ้าน้ำเงินเข้ม สดชัด
              foregroundColor: Colors.white, // ไอคอน/ข้อความสีขาว
              shadowColor: Colors.transparent,
            ),
            icon: const Icon(Icons.add_rounded, size: 18 ),
            label: const Text('สร้างโฟลเดอร์',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            onPressed: () {
              Navigator.push( context,
                PageRouteBuilder(
                  pageBuilder:
                    (context, animation, secondaryAnimation) => FolderPage(user: widget.user),
                    transitionsBuilder: (context, animation,
                      secondaryAnimation, child) {
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
                // ดึงข้อมูลโฟลเดอร์ใหม่ (เพราะแค่เรียกอีกหน้ามาทับ(FolderPage) พอปิดก็ต้องมีการอัพเดต)
              ).then((_) { fetchFolders(); }); 
            },

            
          ),

        ],
      ),
    );
  }
}