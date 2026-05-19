import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLockChatEnabled = false;

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    // High fidelity mock media list for the horizontal media strip
    final List<String> mockMedia = [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&fit=crop',
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&fit=crop',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=200&fit=crop',
      'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=200&fit=crop',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Custom AppBar (Back button & More icon)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: active.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: active.isDark ? Colors.white : Colors.black87, size: 18.r),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: active.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.more_vert_rounded, color: active.isDark ? Colors.white : Colors.black87, size: 18.r),
                      ),
                    ],
                  ),
                ),

                10.verticalSpace,

                // Big User Avatar
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: active.primaryAccent.withOpacity(0.6), width: 2),
                      ),
                      child: widget.user.imageUrl == null
                          ? CircleAvatar(
                              radius: 54.r,
                              backgroundColor: active.primaryAccent.withOpacity(0.12),
                              child: Text(
                                widget.user.name?[0].toUpperCase() ?? '',
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold,
                                  color: active.primaryAccent,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 54.r,
                              backgroundImage: NetworkImage(widget.user.imageUrl!),
                            ),
                    ),
                    Positioned(
                      bottom: 4.r,
                      right: 4.r,
                      child: Container(
                        height: 18.r,
                        width: 18.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // online green
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active.isDark ? const Color(0xFF1E1C24) : Colors.white,
                            width: 2.5,
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                16.verticalSpace,

                // Name & Subtitle
                Text(
                  widget.user.name ?? 'No Name',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: active.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                4.verticalSpace,
                Text(
                  widget.user.username != null ? '@${widget.user.username}' : '+12-6541-1234',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: active.isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),

                24.verticalSpace,

                // Floating row of stats cards (Messages, Group, Spaces)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Message', '12,145', active),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: _buildStatCard('Group', '94', active),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: _buildStatCard('Spaces', '48', active),
                      ),
                    ],
                  ),
                ),

                28.verticalSpace,

                // Media and photos section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Media and photos',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: active.isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: active.isDark ? Colors.white38 : Colors.grey, size: 14.r),
                        ],
                      ),
                      12.verticalSpace,
                      SizedBox(
                        height: 65.h,
                        child: Row(
                          children: List.generate(4, (index) {
                            final isLast = index == 3;
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: index == 3 ? 0 : 8.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: DecorationImage(
                                    image: NetworkImage(mockMedia[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: isLast
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+42',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                28.verticalSpace,

                // List of setting cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: active.isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: active.isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notification',
                          active: active,
                        ),
                        _buildDivider(active),
                        _buildSettingsRow(
                          icon: Icons.image_outlined,
                          label: 'Media visibility',
                          active: active,
                        ),
                        _buildDivider(active),
                        _buildSettingsRow(
                          icon: Icons.bookmark_border_rounded,
                          label: 'Bookmarked',
                          active: active,
                        ),
                        _buildDivider(active),
                        _buildSettingsRow(
                          icon: Icons.lock_outline_rounded,
                          label: 'Lock Chat',
                          active: active,
                          trailing: Switch(
                            value: _isLockChatEnabled,
                            onChanged: (val) {
                              setState(() {
                                _isLockChatEnabled = val;
                              });
                            },
                            activeColor: active.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                30.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count, UiThemePreset active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: active.isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: active.isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: active.isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          4.verticalSpace,
          Text(
            count,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: active.isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    required UiThemePreset active,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, color: active.isDark ? Colors.white60 : Colors.black54, size: 22.r),
          16.horizontalSpace,
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: active.isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          trailing ?? Icon(Icons.arrow_forward_ios_rounded, color: active.isDark ? Colors.white38 : Colors.grey, size: 14.r),
        ],
      ),
    );
  }

  Widget _buildDivider(UiThemePreset active) {
    return Divider(
      height: 1,
      thickness: 1,
      color: active.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}
