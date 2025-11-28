const User = require('../models/User');

/**
 * User Controller
 * Handles user management operations (CRUD)
 */

/**
 * @route   GET /api/users
 * @desc    Get all users
 * @access  Private (Admin/Manager)
 */
exports.getAllUsers = async (req, res, next) => {
  try {
    const users = await User.find().sort({ createdAt: -1 });

    res.status(200).json({
      status: 'success',
      count: users.length,
      users
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/users/:id
 * @desc    Get user by ID
 * @access  Private
 */
exports.getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 'success',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/users
 * @desc    Create new user
 * @access  Private (Admin)
 */
exports.createUser = async (req, res, next) => {
  try {
    const { firstname, lastname, email, password, role } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'Email already exists'
      });
    }

    // Create user
    const user = await User.create({
      firstname,
      lastname,
      email,
      passwordHash: password, // Will be hashed by pre-save hook
      role: role || 'employee'
    });

    res.status(201).json({
      status: 'success',
      message: 'User created successfully',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/users/:id
 * @desc    Update user
 * @access  Private (Admin)
 */
exports.updateUser = async (req, res, next) => {
  try {
    const { firstname, lastname, email, role, active } = req.body;

    const updateData = {};
    if (firstname) updateData.firstname = firstname;
    if (lastname) updateData.lastname = lastname;
    if (email) updateData.email = email;
    if (role) updateData.role = role;
    if (active !== undefined) updateData.active = active;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'User updated successfully',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   DELETE /api/users/:id
 * @desc    Delete user
 * @access  Private (Admin)
 */
exports.deleteUser = async (req, res, next) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'User deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/users/:id/activate
 * @desc    Activate user
 * @access  Private (Admin)
 */
exports.activateUser = async (req, res, next) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { active: true },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'User activated successfully',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/users/:id/deactivate
 * @desc    Deactivate user
 * @access  Private (Admin)
 */
exports.deactivateUser = async (req, res, next) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { active: false },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'User deactivated successfully',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/users/pending
 * @desc    Get pending user registrations
 * @access  Private (Manager/Admin)
 */
exports.getPendingUsers = async (req, res, next) => {
  try {
    const pendingUsers = await User.find({ status: 'pending' })
      .sort({ createdAt: -1 });

    res.status(200).json({
      status: 'success',
      count: pendingUsers.length,
      users: pendingUsers
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/users/:id/validate
 * @desc    Validate/approve pending user registration
 * @access  Private (Manager/Admin)
 */
exports.validateUser = async (req, res, next) => {
  try {
    const { employeeId, department, team } = req.body;

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    if (user.status !== 'pending') {
      return res.status(400).json({
        status: 'error',
        message: `User status is ${user.status}, not pending`
      });
    }

    // Update user status and related fields
    user.status = 'active';
    user.active = true;
    user.validatedBy = req.user._id;
    user.validatedAt = new Date();

    if (employeeId) user.employeeId = employeeId;
    if (department) user.department = department;
    if (team) user.team = team;

    await user.save();

    // TODO: Send confirmation email to user

    res.status(200).json({
      status: 'success',
      message: 'User validated successfully. Account is now active.',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/users/:id/reject
 * @desc    Reject pending user registration
 * @access  Private (Manager/Admin)
 */
exports.rejectUser = async (req, res, next) => {
  try {
    const { reason } = req.body;

    if (!reason) {
      return res.status(400).json({
        status: 'error',
        message: 'Rejection reason is required'
      });
    }

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    if (user.status !== 'pending') {
      return res.status(400).json({
        status: 'error',
        message: `User status is ${user.status}, not pending`
      });
    }

    user.status = 'rejected';
    user.active = false;
    user.rejectionReason = reason;
    user.validatedBy = req.user._id;
    user.validatedAt = new Date();

    await user.save();

    // TODO: Send rejection email to user with reason

    res.status(200).json({
      status: 'success',
      message: 'User registration rejected',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/users/:id/position
 * @desc    Update user position (Manager only)
 * @access  Private (Manager/Admin)
 */
exports.updateUserPosition = async (req, res, next) => {
  try {
    const { position, department, team } = req.body;

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    if (position) user.position = position;
    if (department) user.department = department;
    if (team) user.team = team;

    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'User position updated successfully',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   PUT /api/users/me/location
 * @desc    Update current user's location
 * @access  Private (Employee)
 */
exports.updateMyLocation = async (req, res, next) => {
  try {
    const { address, coordinates, busStop } = req.body;

    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    if (address) user.location.address = address;
    if (coordinates) {
      user.location.coordinates = {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude
      };
    }
    if (busStop) {
      user.location.busStop = {
        name: busStop.name,
        stopId: busStop.stopId
      };
    }

    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Location updated successfully',
      user
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/users/search
 * @desc    Search users by name or email
 * @access  Private
 */
exports.searchUsers = async (req, res, next) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query is required'
      });
    }

    const users = await User.find({
      $or: [
        { firstname: { $regex: q, $options: 'i' } },
        { lastname: { $regex: q, $options: 'i' } },
        { email: { $regex: q, $options: 'i' } }
      ],
      active: true
    }).limit(20);

    res.status(200).json({
      status: 'success',
      count: users.length,
      users
    });
  } catch (error) {
    next(error);
  }
};
