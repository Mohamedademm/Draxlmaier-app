const User = require('../models/User');
const { generateToken } = require('../config/jwt');

/**
 * Authentication Controller
 * Handles user authentication operations
 */

/**
 * @route   POST /api/auth/register
 * @desc    Register new employee (public self-registration)
 * @access  Public
 */
exports.register = async (req, res, next) => {
  try {
    const {
      firstname,
      lastname,
      email,
      password,
      position,
      phone,
      location
    } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'Email already registered'
      });
    }

    // Create new user with pending status
    const user = new User({
      firstname,
      lastname,
      email: email.toLowerCase(),
      passwordHash: password,
      role: 'employee',
      status: 'pending',
      active: false,
      position,
      phone,
      location: {
        address: location?.address,
        coordinates: {
          latitude: location?.coordinates?.latitude,
          longitude: location?.coordinates?.longitude
        },
        busStop: {
          name: location?.busStop?.name,
          stopId: location?.busStop?.stopId
        }
      }
    });

    await user.save();

    // TODO: Send notification to managers about pending registration

    // Remove password from response
    user.passwordHash = undefined;

    res.status(201).json({
      status: 'success',
      message: 'Registration successful. Waiting for manager approval.',
      user: {
        id: user._id,
        email: user.email,
        firstname: user.firstname,
        lastname: user.lastname,
        status: user.status
      }
    });
  } catch (error) {
    next(error);
  }
};

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

    // Check if user status is active
    if (user.status === 'pending') {
      return res.status(403).json({
        status: 'error',
        message: 'Account is pending approval. Please wait for manager validation.'
      });
    }

    if (user.status === 'rejected') {
      return res.status(403).json({
        status: 'error',
        message: 'Account registration was rejected. Please contact HR.'
      });
    }

    // Check if user is active
    if (!user.active || user.status !== 'active') {
      return res.status(403).json({
        status: 'error',
        message: 'Account is deactivated'
      });
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

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
