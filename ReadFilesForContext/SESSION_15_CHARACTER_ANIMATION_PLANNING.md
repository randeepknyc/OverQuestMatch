# Session 15: Character Animation System Planning - Multi-Frame Hand Animation

**Date**: March 27, 2026  
**Status**: 🎯 PLANNING PHASE - No code changes yet  
**User**: Non-coder (requires complete code, no assumptions)

---

## 📋 SESSION OVERVIEW

User wants to implement **multi-frame hand-drawn animations** for character states (idle, attack, hurt, etc.) using PNG sequences. This session focuses on planning and analysis before implementation.

---

## 💬 FULL CONVERSATION TRANSCRIPT

### **USER REQUEST #1:**

> read AI_CONTEXT.md and everything in ReadFilesForContext folder FULLY. going forward provide either applyable or copy pasteable code *ONLY* - ideally applicable, as I don't know how to code. Make no assumptions, if you don't understand something ask clarifying questions. If you need to ask for the full code paste or refresh on folder structure, ask. The biggest thing to prevent since *I do not know how to code* is anything in the app breaking. So always ask questions if you don't understand instead of making assumptions and getting errors or breaking something.
>
> I would like to properly animate the states of the characters - how would i do that? i'll be hand animating the frames and providing pngs

**AI ACTION:**
- Read all context files from ReadFilesForContext folder
- Read AI_CONTEXT.md (not found in current session)
- Read BattleMechanicsConfig.swift (user was viewing MANA line)
- Read session transcripts and documentation
- Identified existing animation system in CharacterAnimations.swift

---

### **AI CLARIFYING QUESTIONS:**

**Question 1: Animation Frame Structure**
- **Option A**: Multiple frames per state? (e.g., `ramp_attack_frame1.png`, `ramp_attack_frame2.png`, `ramp_attack_frame3.png`)
- **Option B**: Single image per state that you'll provide? (e.g., `ramp_attack.png` - just one image)

**Question 2: Animation Type**
- **Option A**: You want the frames to play in sequence like a flipbook (frame 1 → 2 → 3 → back to idle)
- **Option B**: You just want smooth transitions between single images (fade/crossfade between states)

**Question 3: Frame Timing**
If you're doing multi-frame animation:
- How many frames per second should it play? (Common: 12 fps, 24 fps, or 30 fps)
- Should some states have different frame counts? (e.g., attack = 6 frames, hurt = 3 frames)

**Question 4: Which Characters Need Animation?**
- Just **Ramp** (the player)?
- **Ednar** (the enemy) too?
- **Both**?

**Question 5: File Naming Convention**
If using multiple frames, which naming style do you prefer:
- **Option A**: `ramp_attack_1.png`, `ramp_attack_2.png`, `ramp_attack_3.png`
- **Option B**: `ramp_attack_frame1.png`, `ramp_attack_frame2.png`
- **Option C**: Something else you prefer?

**Question 6: Current Issue**
Are you asking because:
- **Option A**: The character portraits currently don't change images at all when states change?
- **Option B**: They change, but you want to add multi-frame animation now?
- **Option C**: Something is broken?

---

### **USER RESPONSES:**

1. **Option A** - Multiple frames per state
2. **Option A** - Flipbook-style frame sequence
3. Frame rate should match `ramp_boil1-3` for idle, frame counts unknown yet, asked for typical state durations
4. **Both** - Ramp and Ednar
5. **`ramp_attack1.png`** naming convention (no underscore before number)
6. **Option B** - They change, but want to add multi-frame animation now

**IMPORTANT USER NOTE:**
> "don't change anything yet, because I want to change mechanics still as well, and that might influence it so i don't want to break everything"

---

## 📊 CURRENT STATE DURATION ANALYSIS

AI analyzed the codebase and provided the following timing breakdown:

### **State Duration Table**

| State | Current Duration | Where It Happens | Notes |
|-------|-----------------|------------------|-------|
| **`.idle`** | **Continuous** (loops forever) | Default state | Line boil animation: 3 frames × 0.15s = 0.45s per cycle |
| **`.attack`** | **350ms** (0.35 seconds) | After matching sword/fire gems | Player attacks enemy |
| **`.hurt`** | **350ms** (0.35 seconds) | Enemy's turn | Enemy attacks player |
| **`.hurt2`** | **350ms** (0.35 seconds) | Invalid swap OR poison damage | Mistake penalty |
| **`.defend`** | **0ms** (instant) | Matching shield gems | Currently NO animation duration |
| **`.spell`** | **0ms** (instant) | Coffee cup ability | Currently NO animation duration |
| **`.victory`** | **Until dismissed** | Win screen | Holds until player taps |
| **`.defeat`** | **Until dismissed** | Lose screen | Holds until player taps |

### **Animation Flow Example**

When player makes a sword match:

```
1. .idle (continuous loop)
   ↓
2. .attack (350ms) ← Player swings sword
   ↓
3. Back to .idle (150ms delay)
   ↓
4. .hurt (350ms) ← Enemy attacks back
   ↓
5. Back to .idle (150ms delay)
   ↓
6. .idle (continuous loop resumes)
```

---

## 🎨 CURRENT IDLE ANIMATION REFERENCE

**Existing `ramp_boil` animation:**
- **3 frames**: `ramp_boil1`, `ramp_boil2`, `ramp_boil3`
- **Speed**: 0.15 seconds per frame
- **Total loop time**: 3 × 0.15s = **0.45 seconds** (about half a second)
- **Frame rate**: ~6.6 FPS
- **Loop type**: Forward loop (1→2→3→1→2→3...)

**Code location**: `CharacterAnimations.swift` - `LineBoilAnimation` struct

---

## 💡 AI RECOMMENDATIONS FOR MULTI-FRAME ANIMATIONS

### **Option 1: Match Idle Speed (Recommended for Most States)**
Good for: `.defend`, `.spell`, `.victory`, `.defeat`

**Why:** These states hold for a while, so slower animation looks natural
- **3 frames** @ **0.15s each** = 0.45s total
- Matches current idle boil animation
- Smooth, relaxed feeling

### **Option 2: Fast Action Animations**
Good for: `.attack`, `.hurt`, `.hurt2`

**Why:** These states only last 350ms, so you need FAST frames

**If using 3 frames:**
- **350ms ÷ 3 frames** = **~117ms per frame** (~8.5 FPS)
- OR just show **2 frames** @ **175ms each** (feels snappier)

**If using 2 frames:**
- **350ms ÷ 2 frames** = **175ms per frame** (~5.7 FPS)
- Simpler, punchier animation

### **Option 3: Single "Hold" Frame**
Good for: Quick states that need impact

**Why:** Sometimes one perfect frame is better than rushed animation
- **1 frame** holds for full **350ms**
- Example: `.hurt` could be single impact frame
- Then maybe add line boil AFTER initial impact

---

## 🎯 SPECIFIC RECOMMENDATIONS BY STATE

| State | Recommended Frame Count | Recommended Speed | Reasoning |
|-------|------------------------|-------------------|-----------|
| **`.idle`** | **3 frames** | **0.15s/frame** | Already perfect! Keep as-is |
| **`.attack`** | **2-3 frames** | **~120ms/frame** | Fast windup → impact. Total 350ms available |
| **`.hurt`** | **2 frames** | **175ms/frame** | Impact → recoil. Clean and readable |
| **`.hurt2`** | **2 frames** | **175ms/frame** | Same as hurt, but different expression |
| **`.defend`** | **3 frames** | **0.15s/frame** | Can loop if needed (like idle) |
| **`.spell`** | **3-4 frames** | **0.15s/frame** | Magical casting motion, can hold longer |
| **`.victory`** | **3-5 frames** | **0.15-0.2s/frame** | Celebratory, can be slower/bouncy |
| **`.defeat`** | **3-4 frames** | **0.15s/frame** | Slump/fall animation |

---

## 🔧 CURRENT SYSTEM BREAKDOWN

### **File Structure:**
- **`CharacterAnimations.swift`** - Handles the line boil animation system
- **`Character.swift`** - Defines states and image names
- **`GameViewModel.swift`** - Controls state timing
- **`BattleManager.swift`** - Triggers state changes

### **Current Animation System:**
- **Idle uses:** `LineBoilAnimation` (3 frames, auto-loops)
- **Other states use:** `StaticImage` (single PNG, no animation)
- **Frame rate:** ~6.6 FPS (0.15s per frame)
- **Loop type:** Simple forward (1→2→3→1→2→3)

### **Existing Code Location:**

**CharacterAnimations.swift - Key Components:**

1. **`StateBasedCharacterPortrait`** - Main switcher that routes to correct portrait system
2. **`RampAnimatedPortrait`** - Switch statement for Ramp's states
3. **`LineBoilAnimation`** - Generic frame animation engine
4. **`StaticImage`** - Single image loader
5. **`StaticCharacterPortrait`** - For non-animated characters (Ednar currently)

**LineBoilAnimation structure:**
```swift
struct LineBoilAnimation: View {
    let framePrefix: String  // e.g., "ramp_boil"
    let frameCount: Int      // e.g., 3
    
    @State private var currentFrame = 0
    
    // Timer at 0.15 seconds per frame (~6.6 FPS)
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        // Cycles through: ramp_boil1, ramp_boil2, ramp_boil3, repeat...
    }
}
```

---

## 📝 CODE CHANGES NEEDED (Not Applied Yet!)

### **Step 1:** Create Animation Configuration File

**New file: `CharacterAnimationConfig.swift`**

```swift
struct CharacterAnimationConfig {
    // Frame counts per state
    static let idleFrames = 3
    static let attackFrames = 3  // User will specify
    static let hurtFrames = 2    // User will specify
    static let hurt2Frames = 2   // User will specify
    static let defendFrames = 3  // User will specify
    static let spellFrames = 3   // User will specify
    static let victoryFrames = 3 // User will specify
    static let defeatFrames = 3  // User will specify
    
    // Frame speeds (seconds per frame)
    static let idleSpeed = 0.15
    static let attackSpeed = 0.12   // Faster for quick action
    static let hurtSpeed = 0.175
    static let hurt2Speed = 0.175
    static let defendSpeed = 0.15
    static let spellSpeed = 0.15
    static let victorySpeed = 0.2   // Slower for celebration
    static let defeatSpeed = 0.15
    
    // Animation behaviors
    enum AnimationBehavior {
        case loop           // Continuous loop (1→2→3→1→2→3)
        case playOnce       // Play once then hold last frame
        case playThenIdle   // Play once then return to idle
    }
    
    static let idleBehavior: AnimationBehavior = .loop
    static let attackBehavior: AnimationBehavior = .playOnce
    static let hurtBehavior: AnimationBehavior = .playOnce
    // etc...
}
```

### **Step 2:** Update `LineBoilAnimation` to Support Custom Speeds

**Modification to CharacterAnimations.swift:**

```swift
struct LineBoilAnimation: View {
    let framePrefix: String
    let frameCount: Int
    let frameSpeed: Double  // ← NEW: Custom speed per animation
    
    @State private var currentFrame = 0
    @State private var timer: Timer?
    
    var body: some View {
        // ... existing code ...
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: frameSpeed, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % frameCount
        }
    }
}
```

### **Step 3:** Update `RampAnimatedPortrait` Switch Statement

```swift
case .attack:
    // OLD:
    StaticImage(imageName: "ramp_attack")
    
    // NEW:
    LineBoilAnimation(
        framePrefix: "ramp_attack",
        frameCount: CharacterAnimationConfig.attackFrames,
        frameSpeed: CharacterAnimationConfig.attackSpeed
    )
```

### **Step 4:** Add Ednar Support

```swift
struct EdnarAnimatedPortrait: View {
    let state: CharacterState
    
    var body: some View {
        switch state {
        case .idle:
            LineBoilAnimation(framePrefix: "ednar_idle", frameCount: 3)
        case .attack:
            LineBoilAnimation(framePrefix: "ednar_attack", frameCount: 3)
        // etc...
        }
    }
}
```

### **Step 5:** (Optional) Extend State Durations for Short States

**GameViewModel.swift modifications:**

```swift
// Currently .defend has 0ms duration - extend it:
case .shield:
    // After setting state
    try? await Task.sleep(for: .milliseconds(400))  // Show defend animation
```

---

## ❓ QUESTIONS FOR USER TO ANSWER BEFORE IMPLEMENTATION

### **1. Frame Counts Per State:**
How many frames will you draw for each state?

- `.attack` = **___ frames** (suggestion: 2-3)
- `.hurt` = **___ frames** (suggestion: 2)
- `.hurt2` = **___ frames** (suggestion: 2)
- `.defend` = **___ frames** (suggestion: 3)
- `.spell` = **___ frames** (suggestion: 3-4)
- `.victory` = **___ frames** (suggestion: 3-5)
- `.defeat` = **___ frames** (suggestion: 3-4)

### **2. Animation Behavior:**

**For short states (attack, hurt, hurt2):**
- **Option A:** Play animation ONCE, then hold last frame until state changes
- **Option B:** Loop animation continuously until state changes
- **Option C:** Play once, then immediately return to idle (might look jarring)

**For defend/spell:**
- These currently have **0ms duration** - should they hold longer?
- Suggested: **400-600ms** so animation is visible
- Or should they loop while shield is active?

**For victory/defeat:**
- These hold forever until dismissed
- **Option A:** Loop animation continuously (celebratory bounce)
- **Option B:** Play once and hold final frame (static pose)

### **3. Frame Rate Consistency:**
- **Option A:** Same speed for all states (0.15s/frame like idle) - simpler
- **Option B:** Custom speed per state (fast attacks, slow victory) - more nuanced
- **Option C:** Just two speeds: "fast" (0.12s) and "slow" (0.15s)

### **4. Ednar Animations:**
Will you provide the same number of frames for Ednar?
- Same frame counts as Ramp?
- Different frame counts?
- Example: `ednar_attack1.png`, `ednar_attack2.png`, `ednar_attack3.png`?

### **5. Mechanics Changes:**
You mentioned wanting to change mechanics too. What are you planning to change?
- State durations?
- When states trigger?
- New states?
- Other gameplay changes?

**Important:** Knowing this helps ensure animation system is flexible enough!

---

## 🎬 IMPLEMENTATION PLAN (When Ready)

### **Phase 1: Configuration Setup**
1. Create `CharacterAnimationConfig.swift`
2. Add all frame counts, speeds, and behaviors
3. User-adjustable settings at top

### **Phase 2: Update Animation Engine**
1. Modify `LineBoilAnimation` to accept custom speeds
2. Add support for different loop behaviors
3. Test with existing `ramp_boil` to ensure no breakage

### **Phase 3: Update Character Portraits**
1. Update `RampAnimatedPortrait` switch cases
2. Change `StaticImage` calls to `LineBoilAnimation` calls
3. Add Ednar support in `StateBasedCharacterPortrait`

### **Phase 4: (Optional) Extend State Durations**
1. Find states with 0ms duration
2. Add appropriate delays
3. Ensure animations are visible

### **Phase 5: Testing**
1. Test each state individually
2. Test state transitions
3. Test in actual gameplay
4. Verify no breakage

---

## 📁 FILES THAT WILL BE MODIFIED (When Implementation Happens)

| File | Changes | Complexity |
|------|---------|------------|
| **CharacterAnimationConfig.swift** | NEW FILE - All animation settings | Low |
| **CharacterAnimations.swift** | Update `LineBoilAnimation` and portrait switches | Medium |
| **GameViewModel.swift** | (Optional) Extend state durations | Low |
| **BattleManager.swift** | (Optional) Extend state durations | Low |

**Files NOT touched:**
- `Character.swift` - No changes needed
- `BattleSceneView.swift` - No changes needed
- `BattleMechanicsConfig.swift` - No changes needed
- All other game logic files

---

## 🚨 IMPORTANT NOTES

### **User Constraints:**
- ✅ Non-coder - needs complete, copy-pasteable code
- ✅ No assumptions - ask clarifying questions first
- ✅ Don't break anything - test before applying
- ✅ Wait for user approval before making changes
- ✅ User wants to change mechanics too - stay flexible

### **Current Status:**
- ⚠️ **NO CODE CHANGES MADE YET**
- ✅ Analysis complete
- ✅ Recommendations provided
- ⏳ Waiting for user answers to questions above

### **What Works Now:**
- ✅ Idle animation with line boil (3 frames)
- ✅ Static images for all other states
- ✅ State switching system
- ✅ Portrait display system

### **What Will Work After:**
- ✅ Multi-frame animation for ALL states
- ✅ Custom frame rates per state
- ✅ Configurable frame counts
- ✅ Support for both Ramp and Ednar
- ✅ User-adjustable animation settings

---

## 🎯 NEXT STEPS FOR USER

### **To Continue This Work in Next Chat:**

Say this to the AI:

> "Read SESSION_15_CHARACTER_ANIMATION_PLANNING.md. I'm ready to implement multi-frame character animations. Here are my answers:
> 
> 1. Frame counts: [your answers]
> 2. Animation behaviors: [your answers]
> 3. Frame rate: [your answer]
> 4. Ednar frames: [yes/no and counts]
> 5. Mechanics changes: [what you're planning]
> 
> Please provide the complete implementation code."

### **Or if you want to change mechanics first:**

> "Read SESSION_15_CHARACTER_ANIMATION_PLANNING.md. Before we do animations, I want to change these mechanics: [describe changes]. Can you help me with that first, then we'll do animations?"

### **Or if you have more questions:**

> "Read SESSION_15_CHARACTER_ANIMATION_PLANNING.md. I have questions about [topic]."

---

## 📊 TECHNICAL DETAILS FOR REFERENCE

### **Current File Structure:**

```
CharacterAnimations.swift:
├── StateBasedCharacterPortrait (main switcher)
│   ├── RampAnimatedPortrait (Ramp's states)
│   │   ├── .idle → LineBoilAnimation
│   │   ├── .attack → StaticImage
│   │   ├── .hurt → StaticImage
│   │   └── etc.
│   ├── StaticCharacterPortrait (Ednar/others)
│   └── FallbackPortrait (error handling)
├── LineBoilAnimation (frame cycling engine)
├── StaticImage (single image loader)
└── Helper views
```

### **How LineBoilAnimation Works:**

```swift
1. framePrefix = "ramp_boil"
2. frameCount = 3
3. Builds sequence: ["ramp_boil1", "ramp_boil2", "ramp_boil3"]
4. Timer fires every 0.15s
5. Increments currentFrame: 0 → 1 → 2 → 0 (loops)
6. Displays corresponding image
```

### **State Timing Code Locations:**

**GameViewModel.swift:**
- Line 564-568: `.attack` animation (350ms)
- Line 843-884: `.hurt` animation during enemy turn (350ms)
- Line 210-230: `.hurt2` animation on invalid swap (350ms)

**BattleManager.swift:**
- Line 84: `.attack` state set on sword match
- Line 93: `.attack` state set on fire match
- Line 110: `.defend` state set on shield match (instant, 0ms)
- Line 125: `.defend` state set on heart match (instant, 0ms)

---

## 💾 BACKUP INSTRUCTIONS

Before implementing, user should:
1. Commit current code to Git (if using version control)
2. Or make a full project backup
3. Or at minimum, copy these files:
   - `CharacterAnimations.swift`
   - `GameViewModel.swift`
   - `BattleManager.swift`

This allows easy revert if needed.

---

## ✅ SESSION SUMMARY

**What Happened:**
1. User requested multi-frame animation system for character states
2. AI read all context files and analyzed current system
3. AI asked 6 clarifying questions
4. User answered all questions
5. AI analyzed current state durations and provided detailed breakdown
6. AI gave recommendations for frame counts and speeds
7. AI prepared implementation plan (NOT executed yet)
8. User requested full transcript for next session

**Decisions Made:**
- ✅ Multi-frame flipbook animation (not crossfades)
- ✅ File naming: `ramp_attack1.png` format
- ✅ Both Ramp and Ednar will get animations
- ✅ Frame rate should match idle (0.15s/frame base)
- ✅ Wait for mechanics changes before implementing

**Decisions Pending:**
- ⏳ Exact frame counts per state
- ⏳ Animation loop behaviors (loop vs play-once)
- ⏳ State duration extensions needed?
- ⏳ Custom speeds per state or uniform?
- ⏳ What mechanics changes are planned?

**Code Status:**
- ✅ No changes made (per user request)
- ✅ System analyzed and documented
- ✅ Ready to implement when user gives go-ahead

---

**End of Session 15 Planning Phase**

**Created**: March 27, 2026  
**Status**: Awaiting user decisions before implementation  
**Risk Level**: Low (analysis only, no code changes)  
**Next Session**: Answer pending questions, then implement OR do mechanics changes first
