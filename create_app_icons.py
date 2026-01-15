from PIL import Image
import os

# Logo path
logo_path = r"C:\Users\HP\Desktop\gym\assets\icons\logo.jpeg"
res_path = r"C:\Users\HP\Desktop\gym\android\app\src\main\res"

# Load the logo
logo = Image.open(logo_path)

# Convert to RGBA if needed
if logo.mode != 'RGBA':
    logo = logo.convert('RGBA')

# Icon sizes for different densities
# Regular launcher icon sizes
launcher_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# Adaptive icon foreground sizes (108dp)
foreground_sizes = {
    'mipmap-mdpi': 108,
    'mipmap-hdpi': 162,
    'mipmap-xhdpi': 216,
    'mipmap-xxhdpi': 324,
    'mipmap-xxxhdpi': 432,
}

# Background color (light pink/white)
bg_color = (255, 255, 255, 255)  # White background

def create_centered_icon(logo_img, size, padding_percent=0.15):
    """Create a square icon with logo centered"""
    # Create background
    icon = Image.new('RGBA', (size, size), bg_color)

    # Calculate logo size with padding
    padding = int(size * padding_percent)
    available_size = size - (2 * padding)

    # Resize logo maintaining aspect ratio
    logo_ratio = logo_img.width / logo_img.height
    if logo_ratio > 1:
        new_width = available_size
        new_height = int(available_size / logo_ratio)
    else:
        new_height = available_size
        new_width = int(available_size * logo_ratio)

    resized_logo = logo_img.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Center the logo
    x = (size - new_width) // 2
    y = (size - new_height) // 2

    # Paste logo onto background
    icon.paste(resized_logo, (x, y), resized_logo)

    return icon

def create_foreground_icon(logo_img, size, padding_percent=0.25):
    """Create adaptive icon foreground with logo centered"""
    # Create transparent background
    icon = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # Calculate logo size with more padding for adaptive icons
    padding = int(size * padding_percent)
    available_size = size - (2 * padding)

    # Resize logo maintaining aspect ratio
    logo_ratio = logo_img.width / logo_img.height
    if logo_ratio > 1:
        new_width = available_size
        new_height = int(available_size / logo_ratio)
    else:
        new_height = available_size
        new_width = int(available_size * logo_ratio)

    resized_logo = logo_img.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Center the logo
    x = (size - new_width) // 2
    y = (size - new_height) // 2

    # Paste logo onto background
    icon.paste(resized_logo, (x, y), resized_logo)

    return icon

def create_background_icon(size):
    """Create solid background for adaptive icon"""
    return Image.new('RGB', (size, size), (255, 255, 255))  # White background

print("Creating app icons...")

# Generate regular launcher icons
for folder, size in launcher_sizes.items():
    folder_path = os.path.join(res_path, folder)
    os.makedirs(folder_path, exist_ok=True)

    icon = create_centered_icon(logo, size, padding_percent=0.1)
    icon_rgb = icon.convert('RGB')
    icon_rgb.save(os.path.join(folder_path, 'ic_launcher.png'), 'PNG')
    print(f"Created {folder}/ic_launcher.png ({size}x{size})")

# Generate adaptive icon foregrounds
for folder, size in foreground_sizes.items():
    folder_path = os.path.join(res_path, folder)
    os.makedirs(folder_path, exist_ok=True)

    # Foreground with logo
    foreground = create_foreground_icon(logo, size, padding_percent=0.25)
    foreground.save(os.path.join(folder_path, 'ic_launcher_foreground.png'), 'PNG')
    print(f"Created {folder}/ic_launcher_foreground.png ({size}x{size})")

    # Background (solid color)
    background = create_background_icon(size)
    background.save(os.path.join(folder_path, 'ic_launcher_background.png'), 'PNG')
    print(f"Created {folder}/ic_launcher_background.png ({size}x{size})")

print("\nAll icons created successfully!")
