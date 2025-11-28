const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/auth');
const { userValidation } = require('../middleware/validation');

/**
 * User Routes
 */

// Get all users (Admin/Manager only)
router.get('/', authenticate, authorize('admin', 'manager'), userController.getAllUsers);

// Get pending registrations (Manager/Admin only)
router.get('/pending', authenticate, authorize('admin', 'manager'), userController.getPendingUsers);

// Search users
router.get('/search', authenticate, userController.searchUsers);

// Get user by ID
router.get('/:id', authenticate, userValidation.getById, userController.getUserById);

// Create user (Admin only)
router.post('/', authenticate, authorize('admin'), userValidation.create, userController.createUser);

// Update user (Admin only)
router.put('/:id', authenticate, authorize('admin'), userValidation.update, userController.updateUser);

// Delete user (Admin only)
router.delete('/:id', authenticate, authorize('admin'), userValidation.getById, userController.deleteUser);

// Activate user (Admin only)
router.post('/:id/activate', authenticate, authorize('admin'), userValidation.getById, userController.activateUser);

// Deactivate user (Admin only)
router.post('/:id/deactivate', authenticate, authorize('admin'), userValidation.getById, userController.deactivateUser);

// Validate pending user (Manager/Admin)
router.put('/:id/validate', authenticate, authorize('admin', 'manager'), userController.validateUser);

// Reject pending user (Manager/Admin)
router.put('/:id/reject', authenticate, authorize('admin', 'manager'), userController.rejectUser);

// Update user position (Manager/Admin)
router.put('/:id/position', authenticate, authorize('admin', 'manager'), userController.updateUserPosition);

// Update my location (Employee)
router.put('/me/location', authenticate, userController.updateMyLocation);

module.exports = router;
