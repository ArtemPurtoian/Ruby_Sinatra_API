# Ruby Sinatra Training API

A lightweight, RESTful API built with **Sinatra** and **Ruby** for training purposes, specifically designed to practice API automation, manual testing, and debugging.

This project implements basic CRUD operations for managing a user collection in-memory and is fully covered by an **RSpec** test suite.

---

## 🚀 Tech Stack

* **Language:** Ruby 4.0.3+
* **Framework:** Sinatra
* **Testing Suite:** RSpec
* **HTTP Test Client:** Rack::Test

---

## 🛠️ API Endpoints

### Welcome & Greetings
* `GET /api/welcome` — Returns a simple welcome message.
* `GET /api/greet/:name` — Greets the user by capitalizing their name.

### User Management (CRUD)
* `GET /api/users` — Retrieves the list of all registered users.
* `POST /api/users` — Creates a new user.
    * **Required Body (JSON):** `{"user_name": "String", "gender": "String", "age": Integer}`
* `PUT /api/users/:id` — Updates an existing user's details by their ID.
* `DELETE /api/users/:id` — Removes a user by their ID.

---

## 📋 Prerequisites

Make sure you have Ruby installed on your machine.

* Clone the repository:
  > git clone https://github.com/ArtemPurtoian/Ruby_Sinatra_API.git

* Navigate to the project directory:
  > cd Ruby_Sinatra_API

* Install dependencies:
  > bundle install

---

## ⚙️ Running the Sinatra API

* Execution of the tests doesn't require separate running of the API.

  However, if you'd like to manually test it - run the app:

* > ruby app.rb

  The API will be available at:
> http://localhost:4567

---

## 🧪 Running Tests

* To run locally with detailed documentation formatting:
  > rspec spec/api_spec.rb --format documentation

---