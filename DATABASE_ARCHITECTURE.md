# Database Architecture & API Strategy

## 📊 PostgreSQL Database Schema

### Tables Structure

```sql
-- Users table (base authentication)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('supplier_company', 'consumer_company', 'driver')),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50),
    date_of_birth DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Companies table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('supplier', 'consumer')),
    address TEXT NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    tax_id VARCHAR(100),
    balance_money DECIMAL(15, 2) DEFAULT 0.00,
    balance_liters DECIMAL(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(user_id)
);

-- Drivers table
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    consumer_company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50),
    license_number VARCHAR(100) NOT NULL,
    vehicle_number VARCHAR(100),
    truck_model VARCHAR(100),
    license_plate VARCHAR(50),
    total_liters_consumed DECIMAL(12, 2) DEFAULT 0.00,
    balance_dzd DECIMAL(15, 2) DEFAULT 0.00,
    monthly_limit DECIMAL(12, 2) DEFAULT 1000.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Transactions table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    initiator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    initiator_name VARCHAR(255) NOT NULL,
    receiver_id UUID REFERENCES users(id) ON DELETE SET NULL,
    receiver_name VARCHAR(255) NOT NULL,
    supplier_company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
    supplier_company_name VARCHAR(255),
    consumer_company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
    consumer_company_name VARCHAR(255),
    amount_liters DECIMAL(12, 2) NOT NULL,
    price_per_liter DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(15, 2) NOT NULL,
    amount_dzd DECIMAL(15, 2) NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_companies_user_id ON companies(user_id);
CREATE INDEX idx_companies_type ON companies(type);
CREATE INDEX idx_drivers_user_id ON drivers(user_id);
CREATE INDEX idx_drivers_company_id ON drivers(consumer_company_id);
CREATE INDEX idx_transactions_initiator ON transactions(initiator_id);
CREATE INDEX idx_transactions_receiver ON transactions(receiver_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_supplier_company ON transactions(supplier_company_id);
CREATE INDEX idx_transactions_consumer_company ON transactions(consumer_company_id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON drivers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## 🏗️ API Architecture Recommendation

### **Recommended Approach: Local-First, Then API Migration**

#### Phase 1: Current State (Local Storage)
✅ **Keep the current implementation** working with SharedPreferences
- Allows immediate testing and deployment
- No infrastructure costs during development
- Faster iteration on features

#### Phase 2: API Development (Parallel)
Build Flask/FastAPI backend while app is in use:

**Tech Stack:**
- **Backend Framework**: FastAPI (Python) - Modern, fast, async support
- **Database**: PostgreSQL 15+
- **Authentication**: JWT tokens
- **Hosting**: 
  - **Development**: Docker + Local/Heroku
  - **Production**: DigitalOcean Droplet or AWS Lightsail

**Why FastAPI over Flask?**
- Built-in async support
- Automatic API documentation (Swagger/OpenAPI)
- Better performance
- Type hints and validation with Pydantic
- WebSocket support for real-time features

#### Phase 3: Migration Strategy
Gradual transition from local to cloud:

1. **Add Sync Button** - Manual sync to server
2. **Background Sync** - Automatic when online
3. **Real-time Sync** - WebSocket for instant updates
4. **Full Cloud** - Remove local storage, use server only

## 🚀 API Endpoints Design

### Authentication
```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/refresh
POST   /api/auth/logout
GET    /api/auth/me
```

### Users
```
GET    /api/users/:id
PUT    /api/users/:id
DELETE /api/users/:id
GET    /api/users/:id/qr-data
```

### Companies
```
GET    /api/companies
GET    /api/companies/:id
POST   /api/companies
PUT    /api/companies/:id
DELETE /api/companies/:id
GET    /api/companies/:id/drivers
GET    /api/companies/:id/transactions
GET    /api/companies/:id/statistics
```

### Drivers
```
GET    /api/drivers
GET    /api/drivers/:id
POST   /api/drivers
PUT    /api/drivers/:id
DELETE /api/drivers/:id
GET    /api/drivers/:id/consumption
PUT    /api/drivers/:id/activate
PUT    /api/drivers/:id/deactivate
```

### Transactions
```
GET    /api/transactions
GET    /api/transactions/:id
POST   /api/transactions
PUT    /api/transactions/:id/approve
PUT    /api/transactions/:id/reject
GET    /api/transactions/pending
GET    /api/transactions/history
POST   /api/transactions/:id/receipt
```

### Real-time (WebSocket)
```
WS     /api/ws/notifications
WS     /api/ws/transactions
```

## 💾 Server & Hosting Requirements

### Development Environment
```
- VPS: 1GB RAM, 1 CPU core
- Storage: 20GB SSD
- Cost: ~$5-10/month (DigitalOcean, Vultr, Linode)
```

### Production Environment
```
- VPS: 2GB RAM, 2 CPU cores
- Storage: 40GB SSD
- Bandwidth: 2TB
- Cost: ~$12-20/month
```

### Recommended Providers
1. **DigitalOcean** - Best balance of cost/performance
2. **AWS Lightsail** - Easy integration with AWS services
3. **Hetzner** - Cheapest option, great performance
4. **Vultr** - Good global coverage

### Database Hosting
**Option 1: Same VPS** (Recommended for start)
- PostgreSQL on same server
- Easier management
- Lower cost

**Option 2: Managed Database**
- DigitalOcean Managed Databases ($15/month)
- AWS RDS
- More reliable, automated backups

## 📦 Docker Setup

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/fuel_tracker
      - JWT_SECRET=your-secret-key
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=fuel_tracker
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - api
    restart: unless-stopped

volumes:
  postgres_data:
```

## 🔐 Security Considerations

1. **Password Hashing**: bcrypt or argon2
2. **JWT Tokens**: Short-lived access tokens + refresh tokens
3. **HTTPS**: Let's Encrypt SSL certificates
4. **Rate Limiting**: Prevent abuse
5. **Input Validation**: Pydantic models
6. **CORS**: Proper configuration for mobile apps
7. **Database**: Connection pooling, prepared statements

## 📱 Mobile App Integration

### Retrofit App for API
```dart
// Add to pubspec.yaml
http: ^1.2.0
dio: ^5.4.0  // Better alternative
flutter_secure_storage: ^9.0.0  // For tokens

// API Service
class ApiService {
  final Dio dio;
  
  Future<void> syncToServer() async {
    // Sync local data to server
  }
  
  Future<void> fetchFromServer() async {
    // Fetch data from server
  }
}
```

## 📈 Migration Timeline

### Week 1-2: Backend Development
- Setup FastAPI project
- Implement database schema
- Create authentication endpoints
- Test with Postman

### Week 3: Core API Endpoints
- User management
- Company CRUD
- Driver management
- Transaction basics

### Week 4: Advanced Features
- Transaction approval flow
- WebSocket notifications
- Receipt generation
- Statistics endpoints

### Week 5: Mobile Integration
- Add API service to Flutter app
- Implement sync mechanism
- Add offline/online indicators
- Test end-to-end

### Week 6: Deployment
- Setup VPS
- Configure domain
- SSL certificates
- Deploy with Docker
- Monitoring and logs

## 💡 Recommendation

**Start with: Local-First Approach**

✅ **Benefits:**
- App works immediately
- No server costs during development
- Easier testing and iteration
- Can deploy to users quickly

**Then add:**
- Backend API in parallel
- Gradual migration
- Optional sync feature
- Full cloud when ready

This approach minimizes risk and allows you to:
1. Get feedback on app functionality
2. Build perfect API based on real usage
3. Avoid infrastructure costs until needed
4. Have working product at all times

Would you like me to:
1. Create the FastAPI backend structure?
2. Add sync functionality to the Flutter app?
3. Setup Docker configuration?
4. Create deployment scripts?
