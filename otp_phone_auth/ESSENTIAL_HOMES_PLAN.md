# Essential Homes - Complete Implementation Plan

## App Overview
**Name**: Essential Homes
**Theme**: Construction Management & Property Development
**Colors**: Navy Blue (#1A237E) + Safety Orange (#FF6D00)
**Design**: Material Design 3, Clean UI, Smooth Animations

## Screen Flow

### 1. Splash Screen ✅ (To Create)
- Essential Homes logo with house + hard hat icon
- Soft gradient background (Navy to Light Blue)
- Loading animation (fade-in + scale)
- Text: "Building the Future"
- Auto-navigate after 2.5 seconds

### 2. Role Selection Screen ✅ (Already Exists - Will Update)
**Current**: `role_selection_screen.dart`
**Updates Needed**:
- Change title to "Select Your Role"
- Update roles to match reference:
  - Supervisor → Field Worker (Orange)
  - Site Engineer → Junior Engineer (Blue)
  - Accountant → Accountant (Green)
  - Architect → Architect (Purple)
  - Owner → Admin (Navy)
- Add role icons matching reference image style
- Highlight selected card with glow effect
- Enable "Continue" button only after selection

### 3. Login Screen ✅ (Already Exists - Will Update)
**Current**: `phone_auth_screen.dart`
**Updates Needed**:
- Add username/email field option
- Keep OTP-based login
- Add "Forgot Password" link
- Inline validation with error messages
- Match reference image layout (cards for role selection above login)

### 4. Main Dashboard ✅ (Already Exists - Will Update)
**Current**: `supervisor_dashboard.dart` (Instagram-style)
**Keep**:
- App bar with app name + profile icon
- Instagram-style stories for active projects
- Card-based layout with smooth scroll
- Bottom navigation with FAB

**Add**:
- Properties section
- Bookings section
- Notifications section

### 5. Profile Page ✅ (Already Exists - Will Update)
**Current**: `profile_form_screen.dart`
**Updates Needed**:
- Accessible from top-right profile icon
- Editable form fields:
  - Full Name
  - Phone Number
  - Email Address
  - Role (non-editable, grayed out)
  - Address
  - Profile picture upload
- Save/Update button (Orange)
- Success toast after update
- Match reference image form style

## Color Scheme (From Reference Image)

### Primary Colors
- **Navy Blue**: #1A237E (Project Manager card)
- **Safety Orange**: #FF6D00 (Field Worker card, buttons)

### Supporting Colors
- **White**: #FFFFFF (backgrounds)
- **Light Gray**: #F5F7FA (form backgrounds)
- **Text Dark**: #1A237E (headings)
- **Text Light**: #455A64 (descriptions)

## Typography (From Reference Image)

### Fonts
- **Headings**: Bold, 20-26px
- **Body**: Regular, 14-16px
- **Buttons**: Semi-bold, 14-16px
- **Labels**: Medium, 12-14px

### Spacing
- Card padding: 16-20px
- Element spacing: 12-16px
- Section spacing: 24-32px

## Components to Create/Update

### New Components
1. ✅ Splash Screen Widget
2. ✅ Role Card Widget (matching reference)
3. ✅ Login Form Widget (with username option)
4. ✅ Profile Picture Upload Widget
5. ✅ Success Toast/Snackbar

### Updated Components
1. ✅ App Theme (ensure Material Design 3)
2. ✅ Role Selection Screen (new design)
3. ✅ Login Screen (add username option)
4. ✅ Profile Form (add picture upload)
5. ✅ Dashboard (add sections)

## Animation Requirements

### Page Transitions
- Splash → Role Selection: Fade + Slide Up
- Role Selection → Login: Slide Left
- Login → Dashboard: Fade + Scale
- Dashboard → Profile: Slide Left

### Element Animations
- Card hover: Scale 1.02 + Shadow increase
- Button press: Scale 0.98
- Form focus: Border color transition
- Loading: Circular progress with fade
- Success: Checkmark animation + fade

### Micro-interactions
- Ripple effect on all buttons
- Smooth scroll on lists
- Pull-to-refresh on dashboard
- Swipe gestures for navigation

## File Structure

```
lib/
├── main.dart (updated with splash)
├── screens/
│   ├── splash_screen.dart (NEW)
│   ├── role_selection_screen.dart (UPDATE)
│   ├── phone_auth_screen.dart (UPDATE - add username)
│   ├── profile_form_screen.dart (UPDATE - add picture)
│   ├── supervisor_dashboard.dart (UPDATE - add sections)
│   └── ... (other dashboards)
├── widgets/
│   ├── role_card_widget.dart (NEW)
│   ├── profile_picture_widget.dart (NEW)
│   ├── custom_button_widget.dart (NEW)
│   └── custom_text_field_widget.dart (NEW)
├── utils/
│   ├── app_colors.dart (KEEP - already perfect)
│   ├── app_theme.dart (UPDATE - ensure MD3)
│   └── animations.dart (NEW)
└── models/
    └── user_model.dart (UPDATE - add profile picture)
```

## Implementation Priority

### Phase 1: Core Screens (High Priority)
1. ✅ Create Splash Screen
2. ✅ Update Role Selection Screen
3. ✅ Update Login Screen
4. ✅ Update Profile Form Screen

### Phase 2: Dashboard Enhancement (Medium Priority)
5. ✅ Add Properties section to dashboard
6. ✅ Add Bookings section to dashboard
7. ✅ Add Notifications section to dashboard
8. ✅ Implement profile navigation

### Phase 3: Polish & Animations (Low Priority)
9. ✅ Add page transition animations
10. ✅ Add micro-interactions
11. ✅ Add loading states
12. ✅ Add success/error feedback

## Technical Stack

### Current (Keep)
- **Platform**: Flutter
- **State Management**: setState (simple)
- **Navigation**: Navigator 2.0
- **Backend**: Firebase (mocked for now)

### New Additions
- **Animations**: AnimatedContainer, Hero, PageRouteBuilder
- **Image Picker**: image_picker package
- **Toast**: fluttertoast package
- **Smooth Animations**: animations package

## Design Principles

### Material Design 3
- ✅ Rounded corners (8-20px)
- ✅ Soft shadows (elevation 1-4)
- ✅ Color system (primary, secondary, tertiary)
- ✅ Typography scale
- ✅ Component states (enabled, disabled, focused)

### Responsive Design
- ✅ Flexible layouts (Expanded, Flexible)
- ✅ MediaQuery for screen sizes
- ✅ SafeArea for notches
- ✅ Adaptive spacing

### Accessibility
- ✅ Semantic labels
- ✅ Sufficient contrast ratios
- ✅ Touch target sizes (48x48 minimum)
- ✅ Screen reader support

## Next Steps

1. Create Splash Screen
2. Update Role Selection with new design
3. Add username option to Login
4. Add profile picture to Profile Form
5. Enhance Dashboard with sections
6. Add smooth animations
7. Test on multiple devices
8. Polish and refine

---

**Status**: Ready to Implement
**Design Reference**: Uploaded image (Navy + Orange theme)
**Target**: Modern, Professional, User-Friendly
