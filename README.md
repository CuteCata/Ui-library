# Roblox UI Library

ไลบรารี UI ที่มีน้ำหนักเบา เหมาะกับมือถือ สำหรับเกม Roblox ด้วยการออกแบบที่สะอาดทันสมัย และแอนิเมชันที่นุ่มนวล

## คุณสมบัติ

- 📱 **เหมาะสำหรับมือถือ**: ควบคุมด้วยการสัมผัสที่เป็นมิตรและเลย์เอาท์ที่ตอบสนอง
- 🎨 **ธีมที่กำหนดเองได้**: ธีมมืด/สว่างในตัวพร้อมรองรับสีแบบกำหนดเอง
- 💾 **การบันทึกการตั้งค่า**: การบันทึก/โหลดค่าปรับแต่งของผู้ใช้โดยอัตโนมัติ
- 🎭 **รองรับไอคอน**: รองรับ Roblox asset IDs และไอคอนรูปร่างพื้นฐาน
- ✨ **แอนิเมชันที่นุ่มนวล**: การเปลี่ยนแปลงแบบ tween และเอฟเฟกต์เมื่อเลื่อนเมาส์
- 🔧 **API ที่ขยายได้**: การออกแบบแบบเชิงวัตถุที่สะอาดเพื่อการปรับแต่งที่ง่าย

## การติดตั้ง

1. สร้าง ModuleScript ใน `ReplicatedStorage` ชื่อ `UILibrary`
2. คัดลอกเนื้อหา `ui_library.lua` ทั้งหมดลงใน ModuleScript
3. เรียกใช้โมดูลใน LocalScript ของคุณ

```lua
local UI = require(game.ReplicatedStorage.UILibrary)
```

## การเริ่มต้นอย่างรวดเร็ว

```lua
-- การตั้งค่าหน้าต่างพื้นฐาน
local UI = require(game.ReplicatedStorage.UILibrary)

local window = UI.CreateWindow({
    Title = "GUI สุดเจ๋งของฉัน",
    Size = UDim2.new(0, 500, 0, 400),
    Theme = "Dark"
})

-- สร้างแท็บ
local mainTab = window:CreateTab("หลัก", "rbxasset://textures/ui/GuiImagePlaceholder.png")

-- สร้างหมวด
local controlsSection = mainTab:CreateSection("การควบคุม")

-- เพิ่มคอมโพเนนต์
local button = controlsSection:CreateButton({
    Name = "คลิกฉัน!",
    Callback = function()
        print("ปุ่มถูกคลิก!")
    end
})

local toggle = controlsSection:CreateToggle({
    Name = "เปิดใช้งานคุณสมบัติ",
    Flag = "EnableFeature",
    Default = true,
    Callback = function(value)
        print("สวิตช์เปลี่ยนเป็น:", value)
    end
})
```

## คู่มือการใช้งาน API

### หน้าต่าง (Window)

#### `UI.CreateWindow(options)`
สร้างหน้าต่างใหม่ด้วยตัวเลือกที่กำหนด

**พารามิเตอร์:**
- `options` (table):
  - `Title` (string, เลือกได้): ชื่อหน้าต่าง (ค่าเริ่มต้น: "UI Library")
  - `Size` (UDim2, เลือกได้): ขนาดหน้าต่าง (ค่าเริ่มต้น: UDim2.new(0, 500, 0, 400))
  - `MinSize` (UDim2, เลือกได้): ขนาดหน้าต่างขั้นต่ำ (ค่าเริ่มต้น: UDim2.new(0, 300, 0, 200))
  - `Theme` (string, เลือกได้): ชื่อธีม ("Dark" หรือ "Light", ค่าเริ่มต้น: "Dark")
  - `Flags` (table, เลือกได้): แฟล็กการกำหนดค่า

**คืนค่า:** วัตถุหน้าต่าง

```lua
local window = UI.CreateWindow({
    Title = "GUI ของฉัน",
    Size = UDim2.new(0, 600, 0, 450),
    Theme = "Light"
})
```

#### เมธอดของหน้าต่าง

- `window:CreateTab(name, icon)` - สร้างแท็บใหม่
- `window:SetCurrentTab(tab)` - เปลี่ยนไปยังแท็บที่กำหนด
- `window:SetTheme(themeName)` - เปลี่ยนธีมหน้าต่าง
- `window:Destroy()` - ทำลายหน้าต่างและบันทึกการกำหนดค่า

### แท็บ (Tab)

#### `window:CreateTab(name, icon)`
สร้างแท็บใหม่ในหน้าต่าง

**พารามิเตอร์:**
- `name` (string): ชื่อที่แสดงของแท็บ
- `icon` (string/number, เลือกได้): ID ของไอคอน asset หรือชื่อรูปร่าง

**คืนค่า:** วัตถุแท็บ

```lua
local tab = window:CreateTab("การตั้งค่า", "rbxassetid://1234567890")
local tab2 = window:CreateTab("การต่อสู้", "circle")
```

#### เมธอดของแท็บ

- `tab:CreateSection(title)` - สร้างหมวดใหม่ในแท็บ

### หมวด (Section)

#### `tab:CreateSection(title)`
สร้างหมวดใหม่ภายในแท็บ

**พารามิเตอร์:**
- `title` (string): ชื่อหมวด

**คืนค่า:** วัตถุหมวด

```lua
local section = tab:CreateSection("การตั้งค่าผู้เล่น")
```

#### เมธอดของหมวด

- `section:CreateButton(options)` - สร้างปุ่ม
- `section:CreateToggle(options)` - สร้างสวิตช์
- `section:CreateSlider(options)` - สร้างแถบเลื่อน
- `section:CreateDropdown(options)` - สร้างเมนูดรอปดาวน์

### ปุ่ม (Button)

#### `section:CreateButton(options)`
สร้างปุ่มที่คลิกได้

**พารามิเตอร์:**
- `options` (table):
  - `Name` (string): ข้อความปุ่ม
  - `Callback` (function): ฟังก์ชันที่เรียกเมื่อคลิก
  - `Enabled` (boolean, เลือกได้): เปิดใช้งานปุ่มหรือไม่ (ค่าเริ่มต้น: true)

**คืนค่า:** วัตถุปุ่ม

```lua
local button = section:CreateButton({
    Name = "บันทึกการตั้งค่า",
    Callback = function()
        print("บันทึกการตั้งค่าแล้ว!")
    end
})
```

#### เมธอดของปุ่ม

- `button:SetEnabled(enabled)` - เปิด/ปิดการใช้งานปุ่ม
- `button:Destroy()` - ลบปุ่ม

### สวิตช์ (Toggle)

#### `section:CreateToggle(options)`
สร้างสวิตช์

**พารามิเตอร์:**
- `options` (table):
  - `Name` (string): ป้ายกำกับสวิตช์
  - `Flag` (string, เลือกได้): แฟล็กการกำหนดค่าสำหรับบันทึก/โหลด
  - `Default` (boolean, เลือกได้): สถานะเริ่มต้น (ค่าเริ่มต้น: false)
  - `Callback` (function, เลือกได้): ฟังก์ชันที่เรียกเมื่อเปลี่ยนสถานะ

**คืนค่า:** วัตถุสวิตช์

```lua
local toggle = section:CreateToggle({
    Name = "บันทึกอัตโนมัติ",
    Flag = "AutoSave",
    Default = true,
    Callback = function(value)
        print("บันทึกอัตโนมัติตอนนี้:", value)
    end
})
```

#### เมธอดของสวิตช์

- `toggle:SetValue(value)` - ตั้งค่าสถานะสวิตช์
- `toggle:Destroy()` - ลบสวิตช์

### แถบเลื่อน (Slider)

#### `section:CreateSlider(options)`
สร้างแถบเลื่อนสำหรับการป้อนตัวเลข

**พารามิเตอร์:**
- `options` (table):
  - `Name` (string): ป้ายกำกับแถบเลื่อน
  - `Min` (number, เลือกได้): ค่าต่ำสุด (ค่าเริ่มต้น: 0)
  - `Max` (number, เลือกได้): ค่าสูงสุด (ค่าเริ่มต้น: 100)
  - `Default` (number, เลือกได้): ค่าเริ่มต้น (ค่าเริ่มต้น: Min)
  - `Increment` (number, เลือกได้): ขนาดขั้น (ค่าเริ่มต้น: 1)
  - `Flag` (string, เลือกได้): แฟล็กการกำหนดค่าสำหรับบันทึก/โหลด
  - `Callback` (function, เลือกได้): ฟังก์ชันที่เรียกเมื่อค่าเปลี่ยนแปลง

**คืนค่า:** วัตถุแถบเลื่อน

```lua
local slider = section:CreateSlider({
    Name = "ระดับเสียง",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Flag = "VolumeLevel",
    Callback = function(value)
        print("ตั้งระดับเสียงเป็น:", value)
    end
})
```

#### เมธอดของแถบเลื่อน

- `slider:SetValue(value)` - ตั้งค่าแถบเลื่อน
- `slider:Destroy()` - ลบแถบเลื่อน

### เมนูดรอปดาวน์ (Dropdown)

#### `section:CreateDropdown(options)`
สร้างเมนูดรอปดาวน์

**พารามิเตอร์:**
- `options` (table):
  - `Name` (string): ป้ายกำกับดรอปดาวน์
  - `Options` (table): อาร์เรย์ของตัวเลือกที่เป็นข้อความ
  - `Default` (string, เลือกได้): การเลือกเริ่มต้น (ค่าเริ่มต้น: ตัวเลือกแรก)
  - `Flag` (string, เลือกได้): แฟล็กการกำหนดค่าสำหรับบันทึก/โหลด
  - `Callback` (function, เลือกได้): ฟังก์ชันที่เรียกเมื่อการเลือกเปลี่ยนแปลง

**คืนค่า:** วัตถุดรอปดาวน์

```lua
local dropdown = section:CreateDropdown({
    Name = "โหมดเกม",
    Options = {"ง่าย", "ปกติ", "ยาก", "ผู้เชี่ยวชาญ"},
    Default = "ปกติ",
    Flag = "GameMode",
    Callback = function(value)
        print("โหมดเกมตั้งเป็น:", value)
    end
})
```

#### เมธอดของดรอปดาวน์

- `dropdown:SetValue(value)` - ตั้งค่าตัวเลือกที่เลือก
- `dropdown:AddOption(option)` - เพิ่มตัวเลือกใหม่
- `dropdown:RemoveOption(option)` - ลบตัวเลือก
- `dropdown:Open()` - เปิดดรอปดาวน์
- `dropdown:Close()` - ปิดดรอปดาวน์
- `dropdown:Destroy()` - ลบดรอปดาวน์

## ธีม

### ธีมในตัว

ไลบรารีมีธีมในตัวสองแบบ:

- **Dark** (ค่าเริ่มต้น): พื้นหลังมืดพร้อมข้อความสว่าง
- **Light**: พื้นหลังสว่างพร้อมข้อความมื่อ

### การใช้ธีม

```lua
-- ตั้งค่าธีมระหว่างการสร้างหน้าต่าง
local window = UI.CreateWindow({
    Title = "GUI ของฉัน",
    Theme = "Light"
})

-- เปลี่ยนธีมหลังจากสร้างแล้ว
window:SetTheme("Dark")

-- ตั้งค่าธีมทั่วไป
UI.SetTheme("Light")
```

### ธีมที่กำหนดเอง

คุณสามารถสร้างธีมที่กำหนดเองได้โดยเพิ่มเข้าไปในไลบรารี:

```lua
UI.AddTheme("กำหนดเอง", {
    Background = Color3.fromRGB(30, 30, 50),
    Secondary = Color3.fromRGB(40, 40, 60),
    Accent = Color3.fromRGB(60, 60, 80),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    Border = Color3.fromRGB(80, 80, 100),
    Success = Color3.fromRGB(0, 200, 100),
    Warning = Color3.fromRGB(255, 200, 0),
    Error = Color3.fromRGB(255, 100, 100)
})

-- จากนั้นใช้มัน
window:SetTheme("กำหนดเอง")
```

## ระบบการกำหนดค่า

ไลบรารีจะบันทึกและโหลดค่าคอมโพเนนต์โดยอัตโนมัติโดยใช้ระบบ `Flag`

### การใช้ Flags

```lua
-- คอมโพเนนต์ที่มี flags จะบันทึก/โหลดค่าของพวกมันโดยอัตโนมัติ
local toggle = section:CreateToggle({
    Name = "เปิดใช้งานการแจ้งเตือน",
    Flag = "NotificationsEnabled",  -- สิ่งนี้จะถูกบันทึก
    Default = true
})

local slider = section:CreateSlider({
    Name = "ระดับเสียงหลัก",
    Flag = "MasterVolume",  -- สิ่งนี้จะถูกบันทึก
    Min = 0,
    Max = 100,
    Default = 75
})
```

### การกำหนดค่าด้วยตนเอง

```lua
-- บันทึกการกำหนดค่าปัจจุบัน
UI.SaveConfig()

-- โหลดการกำหนดค่าที่บันทึกไว้
UI.LoadConfig()
```

## รองรับมือถือ

ไลบรารีได้รับการออกแบบเพื่อทำงานได้อย่างราบรื่นบนอุปกรณ์มือถือ:

- **การควบคุมด้วยการสัมผัส**: คอมโพเนนต์ทั้งหมดตอบสนองต่อการป้อนข้อมูลด้วยการสัมผัส
- **เลย์เอาท์ที่ตอบสนอง**: การปรับขนาดและตำแหน่งโดยอัตโนมัติ
- **รองรับการลาก**: หน้าต่างสามารถลากได้บนอุปกรณ์มือถือ
- **ขนาดที่เหมาะสม**: คอมโพเนนต์มีขนาดที่เหมาะสมสำหรับการสัมผัส

## รองรับไอคอน

ไลบรารีรองรับรูปแบบไอคอนหลายแบบ:

```lua
-- Roblox asset IDs
local tab = window:CreateTab("หน้าหลัก", "rbxassetid://1234567890")

-- Roblox assets
local tab2 = window:CreateTab("การตั้งค่า", "rbxasset://textures/ui/GuiImagePlaceholder.png")

-- รูปร่างพื้นฐาน
local tab3 = window:CreateTab("ข้อมูล", "circle")
local tab4 = window:CreateTab("เครื่องมือ", "square")
```

## ตัวอย่างสมบูรณ์

```lua
local UI = require(game.ReplicatedStorage.UILibrary)

-- สร้างหน้าต่างหลัก
local window = UI.CreateWindow({
    Title = "การตั้งค่าเกม",
    Size = UDim2.new(0, 550, 0, 450),
    Theme = "Dark"
})

-- แท็บหลัก
local mainTab = window:CreateTab("หลัก", "rbxasset://textures/ui/GuiImagePlaceholder.png")
local playerSection = mainTab:CreateSection("การตั้งค่าผู้เล่น")

-- แถบเลื่อนความเร็วผู้เล่น
local speedSlider = playerSection:CreateSlider({
    Name = "ความเร็วในการเดิน",
    Min = 10,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- แถบเลื่อนพลังการกระโดด
local jumpSlider = playerSection:CreateSlider({
    Name = "พลังการกระโดด",
    Min = 20,
    Max = 200,
    Default = 50,
    Flag = "JumpPower",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

-- แท็บกราฟิก
local graphicsTab = window:CreateTab("กราฟิก", "circle")
local visualSection = graphicsTab:CreateSection("การตั้งค่าการแสดงผล")

-- ดรอปดาวน์คุณภาพ
local qualityDropdown = visualSection:CreateDropdown({
    Name = "คุณภาพกราฟิก",
    Options = {"ต่ำ", "ปานกลาง", "สูง", "สูงมาก"},
    Default = "ปานกลาง",
    Flag = "GraphicsQuality",
    Callback = function(value)
        print("คุณภาพกราฟิกตั้งเป็น:", value)
    end
})

-- สวิตช์ VSync
local vsyncToggle = visualSection:CreateToggle({
    Name = "VSync",
    Flag = "VSync",
    Default = true,
    Callback = function(value)
        print("VSync:", value and "เปิดใช้งาน" or "ปิดใช้งาน")
    end
})

-- แท็บเสียง
local audioTab = window:CreateTab("เสียง", "square")
local soundSection = audioTab:CreateSection("การตั้งค่าเสียง")

-- ระดับเสียงหลัก
local masterVolume = soundSection:CreateSlider({
    Name = "ระดับเสียงหลัก",
    Min = 0,
    Max = 100,
    Default = 75,
    Flag = "MasterVolume",
    Callback = function(value)
        game.SoundService.Volume = value / 100
    end
})

-- สวิตช์ปิดเสียง
local muteToggle = soundSection:CreateToggle({
    Name = "ปิดเสียงทั้งหมด",
    Flag = "MuteAll",
    Default = false,
    Callback = function(value)
        game.SoundService.Volume = value and 0 or (masterVolume.Value / 100)
    end
})

-- ปุ่มรีเซต
local resetButton = soundSection:CreateButton({
    Name = "รีเซตเป็นค่าเริ่มต้น",
    Callback = function()
        masterVolume:SetValue(75)
        muteToggle:SetValue(false)
        print("รีเซตการตั้งค่าเสียงเป็นค่าเริ่มต้นแล้ว")
    end
})
```

## เคล็ดลับและแนวทางปฏิบัติที่ดี

1. **ใช้ Flags**: ใช้ flags เสมอสำหรับการตั้งค่าที่คุณต้องการให้คงอยู่ระหว่างเซสชัน
2. **จัดระเบียบด้วยหมวด**: จัดกลุ่มการควบคุมที่เกี่ยวข้องในหมวดเพื่อการจัดระเบียบที่ดีขึ้น
3. **ชื่อที่มีความหมาย**: ใช้ชื่อที่มีความหมายชัดเจนสำหรับคอมโพเนนต์เพื่อปรับปรุงประสบการณ์ของผู้ใช้
4. **ทดสอบบนมือถือ**: ทดสอบ UI ของคุณบนอุปกรณ์มือถือเสมอหากเกมของคุณรองรับพวกมัน
5. **ความสม่ำเสมอของธีม**: ใช้ธีมเดียวตลอดเกมของคุณเพื่อความสม่ำเสมอ
6. **ประสิทธิภาพ**: ทำลายองค์ประกอบ UI เมื่อไม่ต้องการแล้วเพื่อปลดปล่อยหน่วยความจำ

## ใบอนุญาต

ไลบรารีนี้ให้บริการแบบตัวอย่างสำหรับใช้ในเกม Roblox สามารถแก้ไขและแจกจ่ายได้ตามต้องการ
