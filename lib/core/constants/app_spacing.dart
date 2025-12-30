
/// AppSpacing has all spacing and sizing constraints
/// The 8-point grid system meaning All the spacing is a multiple of 8 pixels

class AppSpacing {
  AppSpacing._();

  // ==================== BASE UNIT ====================
  ///base unit = 8.0 pixels
  /// all other spacing are multiple of this
  static const double base = 8.0;

  // ==================== SPACING SCALE ====================
  ///extra small = 4px(0.5 * 8)
  ///use for tiny gaps, tight spacing
  static const double xs = base * 0.5;   //4.0

  /// Small = 8px (1 × 8)
  /// Use for: Small gaps between related items
  static const double sm = base;         // 8.0

  /// Medium = 16px (2 × 8) - MOST COMMON
  /// Use for: Standard padding, margins
  static const double md = base * 2;     // 16.0

  /// Large = 24px (3 × 8)
  /// Use for: Section spacing, card margins
  static const double lg = base * 3;     // 24.0

  /// Extra Large = 32px (4 × 8)
  /// Use for: Large gaps, screen sections
  static const double xl = base * 4;     // 32.0

  /// Extra Extra Large = 48px (6 × 8)
  /// Use for: Major sections, screen padding
  static const double xxl = base * 6;    // 48.0

  // ==================== PADDING SHORTCUTS ====================
  // Quick access to common padding values

  static const double paddingXS = xs;    // 4.0
  static const double paddingSM = sm;    // 8.0
  static const double paddingMD = md;    // 16.0
  static const double paddingLG = lg;    // 24.0
  static const double paddingXL = xl;    // 32.0

  // ==================== SCREEN PADDING ====================
  // Padding from screen edges

  /// Horizontal screen padding = 16px
  /// Use for: Left and right padding of screen content
  static const double screenPaddingH = md;

  /// Vertical screen padding = 24px
  /// Use for: Top and bottom padding of screen content
  static const double screenPaddingV = lg;

  // ==================== CARD STYLING ====================
  // Spacing for card-like components

  /// Card internal padding = 16px
  /// Space inside cards around content
  static const double cardPadding = md;

  /// Card margin = 16px
  /// Space between cards or from screen edge
  static const double cardMargin = md;

  /// Card corner radius = 12px
  /// How rounded the card corners are
  static const double cardRadius = 12.0;

  // ==================== BUTTON STYLING ====================
  // Sizes and spacing for buttons

  /// Standard button height = 56px
  /// All primary buttons should be this height
  static const double buttonHeight = 56.0;

  /// Button horizontal padding = 24px
  /// Space on left and right inside button
  static const double buttonPaddingH = lg;

  /// Button vertical padding = 16px
  /// Space on top and bottom inside button
  static const double buttonPaddingV = md;

  /// Button corner radius = 12px
  /// How rounded the button corners are
  static const double buttonRadius = 12.0;

  // ==================== INPUT FIELD STYLING ====================
  // Sizes and spacing for text input fields

  /// Standard input height = 56px
  /// Matches button height for consistency
  static const double inputHeight = 56.0;

  /// Input internal padding = 16px
  /// Space inside input field around text
  static const double inputPadding = md;

  /// Input corner radius = 12px
  /// How rounded the input corners are
  static const double inputRadius = 12.0;

  // ==================== LIST ITEM STYLING ====================
  // Spacing for list items (like trip history)

  /// Standard list item height = 72px
  /// Height of a row in a list
  static const double listItemHeight = 72.0;

  /// Space between list items = 8px
  static const double listItemSpacing = sm;

  // ==================== ICON SIZES ====================
  // Standard icon sizes for consistency

  static const double iconXS = 16.0;   // Very small icons
  static const double iconSM = 20.0;   // Small icons
  static const double iconMD = 24.0;   // Medium icons (most common)
  static const double iconLG = 32.0;   // Large icons
  static const double iconXL = 48.0;   // Extra large icons

  // ==================== BORDER WIDTHS ====================
  // Thickness of borders and dividers

  static const double borderThin = 1.0;      // Subtle borders
  static const double borderMedium = 2.0;    // Standard borders
  static const double borderThick = 3.0;     // Emphasized borders

}