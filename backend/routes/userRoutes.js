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

module.exports = router;
