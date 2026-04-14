# Calendar UI Design - Client Progress Tab ✅

## New Design Overview

Replaced the dropdown menu with a beautiful calendar-style bottom sheet picker.

---

## Visual Design

### Filter Button (Top Right)
```
┌──────────────┐
│ 📅 Today     │  ← Blue when active, Gray when "All"
└──────────────┘
```

### Calendar Bottom Sheet (When Tapped)
```
┌─────────────────────────────────────────┐
│ 📅 Select Date                      ✕   │ ← Dark blue header
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ 📅 Today  ✓  │  │ 📅 All Dates │   │ ← Quick actions
│  └──────────────┘  └──────────────┘   │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ MAR  📷 Mar 28, 2026      TODAY │  │ ← Date card
│  │  28  1 photo  ☀️ AM            │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ MAR  📷 Mar 27, 2026            │  │
│  │  27  1 photo  ☀️ AM            │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ JAN  📷 Jan 31, 2026            │  │
│  │  31  1 photo  🌙 PM            │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ JAN  📷 Jan 27, 2026            │  │
│  │  27  1 photo  🌙 PM            │  │
│  └─────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

---

## Components

### 1. Header Bar
- **Background**: Dark blue (AppColors.deepNavy)
- **Icon**: Calendar month icon
- **Title**: "Select Date"
- **Close Button**: X icon (top right)

### 2. Quick Action Buttons
Two buttons side by side:

#### Today Button
- **Icon**: 📅 Today icon
- **Text**: "Today"
- **Selected State**: Blue background, white text, check mark
- **Unselected State**: Light gray background, dark text

#### All Dates Button
- **Icon**: 📅 Calendar view month icon
- **Text**: "All Dates"
- **Selected State**: Blue background, white text, check mark
- **Unselected State**: Light gray background, dark text

### 3. Date Cards (Scrollable List)
Each card shows:

#### Left Side: Calendar Icon
- **Size**: 56x56 pixels
- **Shape**: Rounded square
- **Colors**:
  - Today: Green (statusCompleted)
  - Selected: Dark blue (deepNavy)
  - Normal: Light gray
- **Content**:
  - Top: Month abbreviation (MAR, JAN, etc.)
  - Bottom: Day number (28, 27, etc.)

#### Middle: Date Information
- **Line 1**: Full date (Mar 28, 2026) + TODAY badge if applicable
- **Line 2**: Photo count + Time badges
  - Photo count: "1 photo" or "2 photos"
  - Morning badge: ☀️ AM (orange background)
  - Evening badge: 🌙 PM (indigo background)

#### Right Side: Selection Indicator
- **Selected**: Blue check circle (✓)
- **Unselected**: Gray outline circle (○)

---

## Card States

### Today's Date Card
```
┌─────────────────────────────────────┐
│ MAR  📷 Apr 2, 2026      [TODAY]  ✓│
│  2   2 photos  ☀️ AM  🌙 PM       │
└─────────────────────────────────────┘
Green icon | Bold text | Check mark
```

### Selected Date Card
```
┌─────────────────────────────────────┐
│ MAR  📷 Mar 28, 2026              ✓│
│  28  1 photo  ☀️ AM               │
└─────────────────────────────────────┘
Blue icon | Blue border | Check mark
```

### Normal Date Card
```
┌─────────────────────────────────────┐
│ JAN  📷 Jan 27, 2026              ○│
│  27  1 photo  🌙 PM               │
└─────────────────────────────────────┘
Gray icon | Gray border | Outline circle
```

---

## Interactions

### 1. Open Calendar
```
User Action: Tap filter button
Animation: Bottom sheet slides up
Height: 70% of screen
Background: White with rounded top corners
```

### 2. Select Today
```
User Action: Tap "Today" quick action button
Result: 
  - Bottom sheet closes
  - Timeline shows today's photos
  - Filter button shows "Today"
```

### 3. Select Specific Date
```
User Action: Tap a date card
Result:
  - Bottom sheet closes
  - Timeline shows that date's photos
  - Filter button shows date (e.g., "Mar 28")
```

### 4. Select All Dates
```
User Action: Tap "All Dates" quick action button
Result:
  - Bottom sheet closes
  - Timeline shows all photos
  - Filter button shows "All" (gray)
```

### 5. Close Calendar
```
User Action: Tap X button or tap outside
Result: Bottom sheet closes, no changes
```

---

## Color Scheme

### Primary Colors
- **Active Filter**: `AppColors.deepNavy` (Dark Blue)
- **Today Badge**: `AppColors.statusCompleted` (Green)
- **Morning Badge**: Orange (#FF9800)
- **Evening Badge**: Indigo (#3F51B5)

### State Colors
- **Selected Card**: Blue border, light blue background
- **Today Card**: Green calendar icon
- **Normal Card**: Gray border, white background
- **Inactive Filter**: Gray background

---

## Icons Used

### Filter Button
- `Icons.calendar_today` - Calendar icon

### Calendar Header
- `Icons.calendar_month` - Month view icon
- `Icons.close` - Close button

### Quick Actions
- `Icons.today` - Today icon
- `Icons.calendar_view_month` - All dates icon
- `Icons.check` - Check mark (selected)

### Date Cards
- `Icons.photo_library` - Photo count icon
- `Icons.wb_sunny` - Morning/AM icon
- `Icons.nightlight` - Evening/PM icon
- `Icons.check_circle` - Selected indicator
- `Icons.circle_outlined` - Unselected indicator

---

## Responsive Design

### Bottom Sheet Height
- **Default**: 70% of screen height
- **Scrollable**: Yes (for many dates)
- **Rounded Corners**: Top only (20px radius)

### Card Sizing
- **Calendar Icon**: 56x56 pixels
- **Card Height**: Auto (based on content)
- **Card Margin**: 12px bottom spacing
- **Card Padding**: 16px all sides

### Text Sizes
- **Header Title**: 20px, bold
- **Date Text**: 16px, bold
- **Photo Count**: 13px, regular
- **Month (Icon)**: 10px, bold
- **Day (Icon)**: 20px, bold
- **Badge Text**: 9-10px, bold

---

## User Flow

### Default State (Today)
```
1. App opens → Progress tab
2. Auto-loads today's photos
3. Filter shows "Today" (blue)
4. Timeline shows today only
```

### View Different Date
```
1. User taps filter button
2. Calendar sheet slides up
3. User sees:
   - Quick actions (Today, All Dates)
   - List of dates with photo counts
   - Visual indicators (AM/PM badges)
4. User taps a date card
5. Sheet closes
6. Timeline updates to show that date
7. Filter button updates to show date
```

### View All Dates
```
1. User taps filter button
2. Calendar sheet slides up
3. User taps "All Dates" button
4. Sheet closes
5. Timeline shows all dates
6. Filter button shows "All" (gray)
```

---

## Empty State

### No Photos Available
```
┌─────────────────────────────────────┐
│ 📅 Select Date                  ✕  │
├─────────────────────────────────────┤
│  [Today]  [All Dates]              │
├─────────────────────────────────────┤
│                                     │
│         📷                          │
│    No photos available              │
│                                     │
└─────────────────────────────────────┘
```

---

## Advantages Over Dropdown

### Better UX
✅ Visual calendar-style date picker
✅ Shows photo count per date
✅ Shows AM/PM indicators
✅ Larger touch targets
✅ More information at a glance
✅ Professional appearance

### Better Information
✅ See which dates have photos
✅ See how many photos per date
✅ See if morning or evening photos exist
✅ Today is clearly marked
✅ Selected date is obvious

### Better Interaction
✅ Bottom sheet is easier to use
✅ Quick action buttons for common tasks
✅ Scrollable for many dates
✅ Clear close button
✅ Tap outside to dismiss

---

## Technical Details

### Widget Structure
```dart
GestureDetector (Filter Button)
  └─ Container (Styled button)
      └─ Row
          ├─ Icon (calendar_today)
          └─ Text (Today/Date/All)

showModalBottomSheet
  └─ Container (70% height)
      └─ Column
          ├─ Header (Dark blue)
          │   ├─ Icon + Title
          │   └─ Close button
          ├─ Quick Actions Row
          │   ├─ Today button
          │   └─ All Dates button
          ├─ Divider
          └─ ListView (Date cards)
              └─ Date Card
                  ├─ Calendar icon (56x56)
                  ├─ Date info + badges
                  └─ Selection indicator
```

### State Management
```dart
String? _selectedDate;  // Current filter
Map<String, dynamic>? _photosData;  // Photos grouped by date

// On date selection
onDateFilter(filterDate: date);
  └─ _loadPhotos(filterDate: date);
      └─ getClientPhotosByDate(siteId, filterDate);
          └─ setState(() => _photosData = response);
```

---

## Code Highlights

### Calendar Icon with Date
```dart
Container(
  width: 56,
  height: 56,
  decoration: BoxDecoration(
    color: isToday ? green : (isSelected ? blue : gray),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      Text('MAR'),  // Month
      Text('28'),   // Day
    ],
  ),
)
```

### Time Badges
```dart
// Morning badge
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.orange[100],
    borderRadius: BorderRadius.circular(4),
  ),
  child: Row([
    Icon(Icons.wb_sunny, color: Colors.orange[700]),
    Text('AM'),
  ]),
)

// Evening badge
Container(
  decoration: BoxDecoration(color: Colors.indigo[100]),
  child: Row([
    Icon(Icons.nightlight, color: Colors.indigo[700]),
    Text('PM'),
  ]),
)
```

---

## Testing Checklist

- [ ] Filter button appears in Progress tab
- [ ] Tapping filter opens calendar bottom sheet
- [ ] Header shows "Select Date" with close button
- [ ] Quick action buttons work (Today, All Dates)
- [ ] Date cards show calendar icon with month/day
- [ ] Photo count displays correctly
- [ ] AM/PM badges show based on photo times
- [ ] Today's date has green icon and TODAY badge
- [ ] Selected date has blue border and check mark
- [ ] Tapping date card closes sheet and filters
- [ ] Filter button updates to show selection
- [ ] Timeline updates to show filtered photos
- [ ] Empty state shows when no photos

---

## Files Modified

- ✅ `lib/screens/client_dashboard.dart`
  - Replaced `PopupMenuButton` with `showModalBottomSheet`
  - Added `_showCalendarPicker()` method
  - Added `_buildQuickActionButton()` method
  - Added `_buildCalendarDateCard()` method
  - Added `_getMonthShort()` helper
  - Added `_getDay()` helper

---

## Success Criteria ✅

All requirements met:
- [x] Calendar design UI implemented
- [x] Bottom sheet with visual date picker
- [x] Quick action buttons (Today, All Dates)
- [x] Date cards with calendar icons
- [x] Photo count per date
- [x] AM/PM indicators
- [x] Today badge and highlighting
- [x] Selection indicators
- [x] Smooth animations
- [x] Professional appearance
- [x] No compilation errors

---

**Implementation Date**: April 2, 2026
**Status**: ✅ Complete
**Design**: Calendar-Style Date Picker
