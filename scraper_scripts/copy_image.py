import os
import shutil

def copy_image():
    src = r"C:\Users\muham\Desktop\MouseWithoutBorders\ChatGPT Image Jun 4, 2026, 12_17_25 AM.png"
    dest_dir = r"c:\Project\AmarBarishal\assets\images"
    dest = os.path.join(dest_dir, "header_bg.png")
    
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
        
    shutil.copy2(src, dest)
    print(f"Copied to {dest}")

if __name__ == '__main__':
    copy_image()
