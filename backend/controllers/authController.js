const User = require('../models/User');
const { generateToken } = require('../config/jwt');

/**
 * Authentication Controller
 * Handles user authentication operations
 */

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Find user by email and include password
    const user = await User.findOne({ email }).select('+passwordHash');

    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Check if user is active
    if (!user.active) {
      return res.status(403).json({
        status: 'error',
        message: 'Account is deactivated'
      });
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Generate token
    const token = generateToken(user._id);

    // Remove password from response
    user.passwordHash = undefined;

    res.status(200).json({
      status: 'success',
      message: 'Login successful',
      token,
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/auth/me
 * @desc    Get current user
 * @access  Private
 */
exports.getCurrentUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    res.status(200).json({
      status: 'success',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/auth/fcm-token
 * @desc    Update FCM token for push notifications
 * @access  Private
 */
exports.updateFcmToken = async (req, res, next) => {
  try {
    const { fcmToken } = req.body;

    await User.findByIdAndUpdate(req.user._id, { fcmToken });

    res.status(200).json({
      status: 'success',
      message: 'FCM token updated successfully'
    });
  } catch (error) {
    next(error);
  }
};
