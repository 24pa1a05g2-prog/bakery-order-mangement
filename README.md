# Crumb & Co. — Bakery Order Management

A responsive Flutter web dashboard for bakery staff.

## Features
- Dashboard cards for order totals, kitchen queue, ready orders and completed sales
- Create orders with customer, product and quantity
- Search by customer, item or order number
- Filter by Pending, Baking, Ready and Completed
- Update order status
- Menu with sample INR prices
- Responsive desktop and mobile navigation

## Run locally
Install Flutter, then run `flutter pub get` and `flutter run -d chrome`.

## Deployment
A GitHub Actions workflow builds Flutter Web and deploys it to GitHub Pages on every push to `main`.

## Important
This starter app uses in-memory sample data. Orders reset when the app reloads. Connect Firebase or a REST backend before using it for real customer transactions.


Deployment workflow: GitHub Actions builds the Flutter web bundle and publishes it to GitHub Pages after pushes to `main`.
