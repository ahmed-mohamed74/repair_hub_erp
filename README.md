<div align="center">
  <h1> 🛠️ Repair Hub </h1>
  <p><b>A Comprehensive ERP System for Technicians with a Dedicated Customer Tracking Portal.</b></p>
  
  <p>
    <a href="https://radiant-belekoy-3fa6f6.netlify.app/"><strong>Explore the Web Portal »</strong></a>
    <br />
    <br />
    <a href="https://drive.google.com/file/d/1mKordZa5nScnGnQ_QfiW3p_JBh5YML84/view?usp=drive_link">Download Mobile APK</a>
    ·
    <a href="https://github.com/ahmed-mohamed74/repair_hub_erp/issues">Report Bug</a>
  </p>
</div>

<br />

## 📖 Overview
**Repair Hub** is a dual-platform solution designed to streamline repair shop operations. It consists of a **Mobile Management App** for technicians to manage repair tickets and a **Web Tracking Portal** for customers to monitor their device status in real-time. 

The project is built using the **MVVM (Model-View-ViewModel)** pattern to ensure a clean separation between the UI and business logic, providing a scalable and maintainable codebase.

---

## 🖼️ Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img width="180" alt="repair" src="https://github.com/user-attachments/assets/44600040-07cb-40a9-88d1-d163d308f77a" /><br />
        <b>Mobile: Technician App</b>
      </td>
      <td align="center">
        <img width="180" alt="repair1" src="https://github.com/user-attachments/assets/039753e2-3563-4c16-bd47-08a0eeef2df8" /><br />
        <b>Mobile: Repair Tracking</b>
      </td>
      <td align="center">
        <img width="180" alt="repair2" src="https://github.com/user-attachments/assets/5558f290-ca56-4f04-89bd-98068347128a" /><br />
        <b>Mobile: New Ticket</b>
      </td>
    </tr>
    <tr>
      <td colspan="3" align="center">
        <br />
        <img width="500" alt="Customer Website" src="https://github.com/user-attachments/assets/6d762aa8-c03c-412f-814c-045d63531c9b" /><br />
        <b>Web: Customer Tracking Portal</b>
      </td>
    </tr>
  </table>
</div>

---

## 🚀 Key Features
* **Dual-Entry Architecture:** A single codebase serving a full ERP for mobile and a lightweight tracking site for web.
* **Real-time Synchronization:** Powered by **Supabase**, ensuring instant updates between the technician's actions and the customer's view.
* **MVVM Pattern:** Organized code structure separating data models, UI (Views), and business logic (ViewModels).
* **State Management:** Efficient and lightweight logic handling using **Cubit**.
* **Dependency Injection:** Uses **GetIt** for centralized service, repository, and cubit management.
* **Responsive Routing:** Implements **GoRouter** with platform-aware logic to serve different entry points for Web and Mobile.

---

## 🏗️ Architecture & Folder Structure
The project follows a feature-first **MVVM** approach:

* **Core:** Shared constants, Dependency Injection (GetIt) setup, and global utility classes.
* **Features:**
    * **App Home:** Management dashboard for existing tickets.
    * **Add Ticket:** Logic for intake and device documentation.
    * **Ticket Details:** Deep-dive view for specific repair jobs.
    * **Customer Website:** Specialized web-only feature for public ticket tracking.

---

## 🛠️ Tech Stack
* **Frontend:** [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
* **Backend:** [Supabase](https://supabase.com) (PostgreSQL & Real-time)
* **State Management:** [Flutter Cubit](https://pub.dev/packages/flutter_bloc)
* **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
* **Routing:** [GoRouter](https://pub.dev/packages/go_router)
* **Functional Programming:** [Dartz](https://pub.dev/packages/dartz) (Either for Error Handling)

---

## 💻 Setup Instructions
**Clone the repo:**
   ```bash
   git clone https://github.com/ahmed-mohamed74/repair_hub_erp.git
