# iOS Shopping App Case Study

This project is an iOS shopping application developed as a case study to demonstrate
clean architecture, MVVM usage, state management, and user-oriented UI/UX decisions.

---

## Overview

The application starts with a product listing screen where users can browse products,
apply filters, search, sort results, and navigate to product details.  
Users can manage their favorites and shopping cart, and complete a simulated checkout flow.

The focus of this project is code quality, architecture, and user experience rather than
visual fidelity.

---

## Features

### Product Listing
- Products fetched from a remote API
- Infinite scrolling with pagination
- Pull to refresh
- Search by product title, description, and brand
- Category filtering
- Sorting by:
  - Relevance
  - Price (Low to High / High to Low)
  - Rating
  - Discount percentage

### Product Detail
- Image gallery with paging support
- Discounted price calculation
- Add to cart
- Add / remove from favorites
- User feedback via toast messages

### Favorites
- Two-column grid layout
- Discount badge support
- Add to cart directly from favorites
- Remove from favorites with confirmation
- Persistent storage using UserDefaults
- Empty state handling

### Cart
- Quantity increase and decrease
- Remove item with confirmation
- Subtotal calculation with discounts applied
- Persistent cart state
- Cart badge on tab bar
- Empty cart state with navigation back to product list

### Checkout
- Address and card information form
- Delivery option selection
- Payment simulation
- Loading and error states
- Payment success screen
- Cart cleared after successful payment

---

## Architecture

The project follows the MVVM (Model-View-ViewModel) architecture.

### ViewModels
- ProductListViewModel
- ProductDetailViewModel
- FavoritesViewModel
- CartViewModel
- CheckoutViewModel

ViewModels:
- Contain all business logic
- Are independent of UIKit
- Expose state changes via closures

### Services
- ProductService  
  Responsible for networking and API communication using async/await.
- ImageLoader  
  Lightweight image loading with in-memory caching.

### Stores
- CartStore
- FavoritesStore

Stores:
- Manage global application state
- Handle persistence
- Notify listeners when data changes

---

## State Management

- Networking is implemented using async/await and URLSession
- ViewModels communicate with Views using simple callback bindings
- Global state (cart and favorites) is centralized in store objects
- UI updates react to state changes in a predictable way

RxSwift was intentionally not used to keep the project lightweight and dependency-free.

---

## Persistence

- Favorites and cart data are persisted using UserDefaults
- Application state is restored when the app is reopened

---

## Testing

Unit tests focus on:
- ViewModel business logic
- Filtering, searching, and sorting behavior
- Price and discount calculations
- Cart subtotal calculations
- Persistence logic

Tests are written using XCTest.

---

## UI and UX Considerations

- UIKit-based implementation without Storyboards
- Clear visual hierarchy and spacing
- Reduced visual noise using soft background colors
- Meaningful empty states
- Confirmation dialogs for destructive actions
- Toast-style feedback for user actions
- Bottom action bars for primary actions

Provided designs were used as a reference and adjusted where necessary.

---

## Technologies Used

- Swift
- UIKit
- MVVM
- Async / Await
- URLSession
- UserDefaults
- XCTest

---

## How to Run

1. Clone the repository
2. Open the Xcode project file
3. Run on an iOS Simulator (iOS 16 or later recommended)

---

## Author

Ahmet Cemil Özen  
iOS Developer
