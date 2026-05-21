import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/providers/ui_theme_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/start_chat_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class StartChatScreen extends StatefulWidget {
  const StartChatScreen({super.key});

  @override
  State<StartChatScreen> createState() => _StartChatScreenState();
}

class _StartChatScreenState extends State<StartChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final uiTheme = Provider.of<UiThemeProvider>(context);
    final active = uiTheme.activePreset;

    return ChangeNotifierProvider(
      create: (context) => StartChatViewmodel(DatabaseService(), currentUser!),
      child: Consumer<StartChatViewmodel>(builder: (context, model, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: active.isDark ? Colors.white : Colors.black87,
                  size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Start Chat',
              style: h.copyWith(
                color: active.isDark ? Colors.white : Colors.black87,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: _searchController,
                    onChanged: model.search,
                    style: TextStyle(
                      color: active.isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: TextStyle(
                        color: active.isDark ? Colors.white38 : Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: active.isDark ? Colors.white54 : Colors.black54,
                      ),
                      filled: true,
                      fillColor: active.isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                16.verticalSpace,
                model.state == ViewState.loading
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : model.filteredUsers.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Text(
                                "No users found",
                                style: body.copyWith(
                                  color: active.isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              itemCount: model.filteredUsers.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              itemBuilder: (context, index) {
                                final user = model.filteredUsers[index];
                                return _buildUserTile(user, active, context);
                              },
                            ),
                          )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserTile(UserModel user, UiThemePreset active, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: active.isDark
              ? Colors.white.withOpacity(0.03)
              : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: active.isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: () {
            // Navigate to ChatScreen directly
            Navigator.pushNamed(context, chatRoom, arguments: user);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: Stack(
            children: [
              user.imageUrl == null
                  ? CircleAvatar(
                      backgroundColor: active.primaryAccent.withOpacity(0.1),
                      radius: 25.r,
                      child: Text(
                        user.name != null && user.name!.isNotEmpty
                            ? user.name![0].toUpperCase()
                            : "?",
                        style: h.copyWith(
                          color: active.primaryAccent,
                          fontSize: 20.sp,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Image.network(
                        user.imageUrl!,
                        height: 50.r,
                        width: 50.r,
                        fit: BoxFit.cover,
                      ),
                    ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 12.r,
                  width: 12.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Online green
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active.isDark ? const Color(0xFF1E1C24) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            user.name ?? 'Unknown',
            style: body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: active.isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            user.email ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body.copyWith(
              color: active.isDark ? Colors.white54 : grey,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}
