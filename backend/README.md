# GYM Fitness Backend API

Backend API server for GYM Fitness mobile application built with Node.js, Express, and MongoDB.

## 🚀 Features

- User Authentication (JWT)
- User Profile Management
- Workout Tracking
- Meal Planning & Nutrition Tracking
- Subscription Management
- Trainer Management
- Workshop Management
- Progress Tracking & Analytics
- File Upload (Profile Pictures)

## 📋 Prerequisites

- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn

## 🔧 Installation

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create .env file and configure
cp .env.example .env

# Start MongoDB service
# Windows: net start MongoDB
# Mac/Linux: sudo systemctl start mongod

# Start development server
npm run dev

# Or start production server
npm start
```

## 🌐 API Endpoints

### Authentication
```
POST   /api/auth/register     - Register new user
POST   /api/auth/login        - Login user
POST   /api/auth/logout       - Logout user
GET    /api/auth/me           - Get current user
PUT    /api/auth/updatepassword - Update password
```

### Users
```
GET    /api/users             - Get all users (admin)
GET    /api/users/:id         - Get user by ID
PUT    /api/users/:id         - Update user
DELETE /api/users/:id         - Delete user (admin)
PUT    /api/users/:id/stats   - Update user stats
```

### Workouts
```
GET    /api/workouts          - Get user workouts
POST   /api/workouts          - Create new workout
GET    /api/workouts/:id      - Get workout by ID
PUT    /api/workouts/:id      - Update workout
DELETE /api/workouts/:id      - Delete workout
PUT    /api/workouts/:id/complete - Mark workout as completed
```

### Meals
```
GET    /api/meals             - Get user meals
POST   /api/meals             - Create new meal
GET    /api/meals/:id         - Get meal by ID
PUT    /api/meals/:id         - Update meal
DELETE /api/meals/:id         - Delete meal
GET    /api/meals/daily-nutrition - Get daily nutrition summary
```

### Subscriptions
```
GET    /api/subscriptions     - Get all subscription plans
POST   /api/subscriptions     - Create subscription plan (admin)
GET    /api/subscriptions/:id - Get subscription by ID
PUT    /api/subscriptions/:id - Update subscription (admin)
POST   /api/subscriptions/subscribe - Subscribe to plan
DELETE /api/subscriptions/cancel - Cancel subscription
```

### Trainers
```
GET    /api/trainers          - Get all trainers
POST   /api/trainers          - Create trainer (admin)
GET    /api/trainers/:id      - Get trainer by ID
PUT    /api/trainers/:id      - Update trainer (admin)
DELETE /api/trainers/:id      - Delete trainer (admin)
GET    /api/trainers/:id/schedule - Get trainer schedule
```

### Workshops
```
GET    /api/workshops         - Get all workshops
POST   /api/workshops         - Create workshop (admin)
GET    /api/workshops/:id     - Get workshop by ID
PUT    /api/workshops/:id     - Update workshop (admin)
DELETE /api/workshops/:id     - Delete workshop (admin)
POST   /api/workshops/:id/enroll - Enroll in workshop
DELETE /api/workshops/:id/unenroll - Cancel enrollment
```

### Progress
```
GET    /api/progress          - Get user progress
POST   /api/progress/weight   - Log weight entry
POST   /api/progress/measurements - Log body measurements
GET    /api/progress/stats    - Get progress statistics
GET    /api/progress/weekly-activity - Get weekly activity
```

## 📝 Request Examples

### Register User
```json
POST /api/auth/register
Content-Type: application/json

{
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "password": "123456",
  "phone": "0501234567",
  "age": 25,
  "gender": "male",
  "height": 175,
  "weight": 75
}
```

### Create Workout
```json
POST /api/workouts
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "تمرين الصدر والكتف",
  "category": "strength",
  "duration": 45,
  "caloriesBurned": 350,
  "difficulty": "intermediate",
  "exercises": [
    {
      "name": "Bench Press",
      "sets": 4,
      "reps": 10,
      "restTime": 90
    },
    {
      "name": "Shoulder Press",
      "sets": 3,
      "reps": 12,
      "restTime": 60
    }
  ]
}
```

### Create Meal
```json
POST /api/meals
Authorization: Bearer <token>
Content-Type: application/json

{
  "mealType": "breakfast",
  "title": "إفطار صحي",
  "time": "08:00",
  "foods": [
    {
      "name": "شوفان",
      "quantity": 50,
      "unit": "grams",
      "calories": 190,
      "protein": 7,
      "carbs": 34,
      "fat": 3
    },
    {
      "name": "موز",
      "quantity": 1,
      "unit": "piece",
      "calories": 105,
      "protein": 1,
      "carbs": 27,
      "fat": 0
    }
  ]
}
```

## 🗂️ Database Models

### User Model
- `name`: String (required)
- `email`: String (required, unique)
- `password`: String (required, hashed)
- `phone`: String
- `age`: Number
- `gender`: Enum ['male', 'female']
- `height`: Number (cm)
- `weight`: Number (kg)
- `profileImage`: String
- `role`: Enum ['user', 'trainer', 'admin']
- `subscription`: ObjectId (ref: Subscription)
- `stats`: Object (totalWorkouts, totalCaloriesBurned, etc.)

### Workout Model
- `user`: ObjectId (ref: User)
- `title`: String (required)
- `category`: Enum ['cardio', 'strength', 'flexibility', 'sports', 'other']
- `duration`: Number (minutes)
- `caloriesBurned`: Number
- `difficulty`: Enum ['beginner', 'intermediate', 'advanced']
- `exercises`: Array of exercise objects
- `date`: Date
- `completed`: Boolean

### Meal Model
- `user`: ObjectId (ref: User)
- `mealType`: Enum ['breakfast', 'lunch', 'dinner', 'snack']
- `title`: String (required)
- `foods`: Array of food objects
- `totalNutrition`: Object (calories, protein, carbs, fat)
- `date`: Date
- `time`: String
- `completed`: Boolean

## 🔒 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## 🐛 Error Handling

All API responses follow this format:

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message here"
}
```

## 📊 Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

## 🔧 Environment Variables

```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/gym_db
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRE=7d
MAX_FILE_SIZE=5242880
```

## 📦 Dependencies

- express: Web framework
- mongoose: MongoDB ODM
- bcryptjs: Password hashing
- jsonwebtoken: JWT authentication
- dotenv: Environment variables
- cors: Cross-origin resource sharing
- express-validator: Input validation
- multer: File uploads

## 🚀 Deployment

### Using PM2
```bash
# Install PM2 globally
npm install -g pm2

# Start application
pm2 start server.js --name gym-api

# Monitor
pm2 monit

# Stop
pm2 stop gym-api
```

### Using Docker
```bash
# Build image
docker build -t gym-api .

# Run container
docker run -p 5000:5000 gym-api
```

## 📱 Integration with Flutter App

Update the API base URL in your Flutter app:

```dart
class ApiService {
  static const String baseUrl = 'http://your-server-ip:5000/api';

  // Your API methods here
}
```

## 👨‍💻 Development

```bash
# Run tests
npm test

# Run linter
npm run lint

# Format code
npm run format
```

## 📄 License

MIT License

## 👥 Contributors

- Your Name

## 📞 Support

For support, email support@gymfitness.com
