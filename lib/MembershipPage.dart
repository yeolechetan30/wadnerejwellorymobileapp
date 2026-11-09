import 'package:flutter/material.dart';

class Membershippage extends StatefulWidget {
  const Membershippage({super.key});

  @override
  State<Membershippage> createState() => _MembershippageState();
}

class _MembershippageState extends State<Membershippage> {
  // ==========================================================
  // THEME
  // ==========================================================

  static const Color navy = Color(0xFF101D2D);
  static const Color navyDark = Color(0xFF0A1422);
  static const Color navyLight = Color(0xFF1D3046);

  static const Color gold = Color(0xFFD4A72C);
  static const Color goldLight = Color(0xFFE8CB70);
  static const Color goldDark = Color(0xFFB88918);

  static const Color cream = Color(0xFFFFFCF4);
  static const Color textDark = Color(0xFF172333);

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final nameController =
  TextEditingController(text: '');

  final mobileController =
  TextEditingController(text: '');

  final depositController =
  TextEditingController(text: '');

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    depositController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),

              child: Container(
                decoration: BoxDecoration(
                  color: cream,
               //   borderRadius: BorderRadius.circular(2),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22),bottomRight: Radius.circular(22),topLeft: Radius.circular(5),topRight: Radius.circular(5)),

                /*  border: Border.all(
                    color: gold,
                    width: 2,
                  ),*/
                  border: Border.all(color: gold,width: 2),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.35),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                clipBehavior: Clip.antiAlias,

                child: Column(
                  children: [

                    // ==================================================
                    // HEADER
                    // ==================================================

                    _buildHeader(),

                    // ==================================================
                    // FORM BODY
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        30,
                        26,
                        30,
                        22,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          // LOGIN STATUS
                          _buildLoggedInStatus(),

                          const SizedBox(height: 22),

                          // NAME
                          _buildLabel('Full Name'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: nameController,
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 18),

                          // MOBILE
                          _buildLabel('Mobile Number'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: mobileController,
                            hint: 'Enter mobile number',
                            icon: Icons.phone_outlined,
                            keyboardType:
                            TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          // MEMBERSHIP FEE
                          _buildFeeBox(),

                          const SizedBox(height: 18),

                          // DEPOSIT
                          _buildLabel(
                            'Initial Deposit Amount (₹)',
                          ),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: depositController,
                            hint: 'Enter amount',
                            icon: Icons.currency_rupee,
                            keyboardType:
                            TextInputType.number,
                          ),

                          const SizedBox(height: 22),

                          // PAYMENT
                          _buildPaymentButton(),

                          const SizedBox(height: 20),

                          // FOOTER
                          _buildAlreadyMemberText(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            navyDark,
            navy,
            navyLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: Border(
          bottom: BorderSide(
            color: gold,
            width: 4,
          ),
        ),
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 21,
      ),

      child: Row(
        children: [

          // PREMIUM ICON
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: gold.withOpacity(.12),
              shape: BoxShape.circle,

              border: Border.all(
                color: gold,
                width: 1.2,
              ),
            ),

            child: const Icon(
              Icons.card_membership_outlined,
              color: goldLight,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              'Join Membership',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: .3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOGGED IN STATUS
  // ==========================================================

  Widget _buildLoggedInStatus() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: navy,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: gold,
          width: 1,
        ),
      ),

      child: const Row(
        children: [

          Icon(
            Icons.check_circle,
            color: goldLight,
            size: 21,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Logged In Details Auto-Loaded',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LABEL
  // ==========================================================

  Widget _buildLabel(String text) {
    return Text(
      text,

      style: const TextStyle(
        color: navy,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,

      keyboardType: keyboardType,

      maxLines: maxLines,

      maxLength: maxLength,

      style: const TextStyle(
        color: textDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        counterText: '',

        hintText: hint,

        hintStyle: TextStyle(
          color: navy.withOpacity(.40),
          fontSize: 14,
        ),

        prefixIcon: Icon(
          icon,
          color: goldDark,
          size: 21,
        ),

        filled: true,

        fillColor: Colors.white,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),

          borderSide:
          const BorderSide(
            color: gold,
            width: 1.2,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),

          borderSide:
          const BorderSide(
            color: goldDark,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MEMBERSHIP FEE
  // ==========================================================

  Widget _buildFeeBox() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DF),

        borderRadius:
        BorderRadius.circular(10),

        border: Border.all(
          color: gold,
          width: 1.2,
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: gold.withOpacity(.15),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.workspace_premium_outlined,
              color: goldDark,
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                ),

                children: [

                  TextSpan(
                    text:
                    'Membership Registration Fee:  ',
                  ),

                  TextSpan(
                    text: '₹ 100.00',

                    style: TextStyle(
                      color: navy,
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAYMENT BUTTON
  // ==========================================================

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton(
        onPressed: _proceedToPayment,

        style: ElevatedButton.styleFrom(
          backgroundColor: navy,

          foregroundColor: goldLight,

          elevation: 4,

          shadowColor:
          navy.withOpacity(.35),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10),

            side: const BorderSide(
              color: gold,
              width: 1.4,
            ),
          ),
        ),

        child: const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              Icons.payment_outlined,
              color: goldLight,
              size: 20,
            ),

            SizedBox(width: 9),

            Text(
              'PROCEED TO PAY (₹1100)',
              style: TextStyle(
                color: goldLight,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FOOTER
  // ==========================================================

  Widget _buildAlreadyMemberText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,

        text: const TextSpan(
          style: TextStyle(
            color: Color(0xFF9A7312),
            fontSize: 14,
          ),

          children: [

            TextSpan(
              text: '* ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            TextSpan(
              text: 'If already enrolled: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            TextSpan(
              text:
              '"You are already a member"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PAYMENT
  // ==========================================================

  void _proceedToPayment() {
    final name =
    nameController.text.trim();

    final mobile =
    mobileController.text.trim();

    final deposit =
    depositController.text.trim();

    if (name.isEmpty ||
        mobile.isEmpty ||
        deposit.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required details',
          ),
        ),
      );

      return;
    }

    debugPrint('Name: $name');
    debugPrint('Mobile: $mobile');
    debugPrint('Deposit: $deposit');

    // TODO: Payment gateway
  }
}