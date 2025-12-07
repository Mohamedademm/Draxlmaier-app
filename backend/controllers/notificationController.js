const Notification = require('../models/Notification');
const User = require('../models/User');

/**
 * Notification Controller
 * Handles notification operations
 */

/**
 * @route   GET /api/notifications
 * @desc    Get all notifications for current user
 * @access  Private
 */
exports.getNotifications = async (req, res, next) => {
  try {
    const userId = req.user._id;

    // Find notifications where user is in targetUsers array OR targetUsers is empty (broadcast)
    const notifications = await Notification.find({
      $or: [
        { targetUsers: userId },
        { targetUsers: { $exists: true, $size: 0 } }
      ]
    })
      .populate('senderId', 'firstname lastname email')
      .sort({ timestamp: -1 });

    console.log(`Found ${notifications.length} notifications for user ${userId}`);

    res.status(200).json({
      status: 'success',
      count: notifications.length,
      notifications
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    next(error);
  }
};

/**
 * @route   POST /api/notifications/send
 * @desc    Send notification
 * @access  Private (Admin/Manager)
 */
exports.sendNotification = async (req, res, next) => {
  try {
    const { title, message, targetUsers } = req.body;
    const senderId = req.user._id;

    // Validate required fields
    if (!title || !message) {
      return res.status(400).json({
        status: 'error',
        message: 'Title and message are required'
      });
    }

    // If targetUsers is empty, send to all active users
    let recipients = targetUsers;
    if (!recipients || recipients.length === 0) {
      const users = await User.find({ active: true, _id: { $ne: senderId } });
      recipients = users.map(user => user._id);
    }

    const notification = await Notification.create({
      title,
      message,
      senderId,
      targetUsers: recipients
    });

    const populatedNotification = await Notification.findById(notification._id)
      .populate('senderId', 'firstname lastname email');

    // TODO: Send push notifications via FCM here

    res.status(201).json({
      status: 'success',
      message: 'Notification sent successfully',
      notification: populatedNotification
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
exports.markAsRead = async (req, res, next) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user._id;

    const notification = await Notification.findById(notificationId);

    if (!notification) {
      return res.status(404).json({
        status: 'error',
        message: 'Notification not found'
      });
    }

    // Check if user is a target
    if (!notification.targetUsers.includes(userId)) {
      return res.status(403).json({
        status: 'error',
        message: 'You are not authorized to access this notification'
      });
    }

    // Mark as read
    await notification.markAsReadBy(userId);

    res.status(200).json({
      status: 'success',
      message: 'Notification marked as read'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/notifications/unread-count
 * @desc    Get unread notification count
 * @access  Private
 */
exports.getUnreadCount = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const count = await Notification.countDocuments({
      targetUsers: userId,
      readBy: { $ne: userId }
    });

    res.status(200).json({
      status: 'success',
      count
    });
  } catch (error) {
    next(error);
  }
};
