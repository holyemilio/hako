# What didn't work

Written for: anyone reading this repo, including people who want to learn from a product that didn't work out.

Hako is archived. These are the decisions I'd make differently, in rough order of how much they cost.

## 1. I built before I validated the problem

I designed 39 screens and built about 2,300 lines of SwiftUI before I had talked to enough people who would actually use the app. The design work came first, so every feature I added made the app harder to drop later.

**What I'd do instead:** write down the core user behavior ("what would someone do every week?") and test it with a paper prototype or a short survey before writing any screen.

## 2. I assumed people would enter data for every product

The core idea required users to photograph products, scan barcodes, and set an expiry date for each item. Feedback made clear that people won't do this. The problem wasn't the interface: the workflow itself asked too much.

**What I'd do instead:** ask what people already do when they think about food expiry, and design around that, not around a complete inventory.

## 3. The barcode solved the wrong problem

Even if the barcode scan worked, it only identifies the product. It doesn't give its expiry date, so the user still has to enter the most important information by hand. The scanning feature reduced the wrong part of the effort.

**What I'd do instead:** check whether each proposed feature removes the hardest step for the user, not just a visible step.

## 4. Mockups got ahead of the code

The mockups show a camera flow (screens 10 to 13) that was never implemented. The food-category dictionary is still a placeholder, and the freezer shelf-life table is still empty. The docs described a more complete app than the one that existed.

**What I'd do instead:** mark each mockup as "planned", "built", or "dropped", and keep that status next to the file.

## 5. Tooling problems cost time

Xcode was installed, but the system pointed to the Command Line Tools, so the iOS Simulator wouldn't start. I didn't check this early, and I lost time to it. The project also had no version control until the end and no test target.

**What I'd do instead:** check the toolchain on day one, put the project under git from the first commit, and add at least a basic test target.

## What still holds up

- The data model (dispensa, scomparti, prodotti, persone, freezer) is reasonable, and the store handles persistence and notifications.
- The reference tables (categories, shapes, environments, non-expiring foods) are useful outside this app.
- The build succeeds for iOS Simulator with full Xcode.
