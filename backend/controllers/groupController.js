const ChatGroup = require('../models/ChatGroup');

/**
 * Group Controller
 * Handles chat group operations
 */

/**
 * @route   GET /api/groups
 * @desc    Get all groups for current user
 * @access  Private
 */
exports.getAllGroups = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const groups = await ChatGroup.find({ members: userId })
      .populate('members', 'firstname lastname email')
      .populate('createdBy', 'firstname lastname email')
      .sort({ createdAt: -1 });

    res.status(200).json({
      status: 'success',
      count: groups.length,
      groups
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   GET /api/groups/:id
 * @desc    Get group by ID
 * @access  Private
 */
exports.getGroupById = async (req, res, next) => {
  try {
    const group = await ChatGroup.findById(req.params.id)
      .populate('members', 'firstname lastname email')
      .populate('createdBy', 'firstname lastname email');

    if (!group) {
      return res.status(404).json({
        status: 'error',
        message: 'Group not found'
      });
    }

    // Check if user is a member
    if (!group.members.some(member => member._id.toString() === req.user._id.toString())) {
      return res.status(403).json({
        status: 'error',
        message: 'You are not a member of this group'
      });
    }

    res.status(200).json({
      status: 'success',
      group
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/groups
 * @desc    Create new group
 * @access  Private
 */
exports.createGroup = async (req, res, next) => {
  try {
    const { name, members } = req.body;
    const userId = req.user._id;

    // Add creator to members if not already included
    const memberSet = new Set([...members, userId.toString()]);

    const group = await ChatGroup.create({
      name,
      members: Array.from(memberSet),
      createdBy: userId
    });

    const populatedGroup = await ChatGroup.findById(group._id)
      .populate('members', 'firstname lastname email')
      .populate('createdBy', 'firstname lastname email');

    res.status(201).json({
      status: 'success',
      message: 'Group created successfully',
      group: populatedGroup
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   POST /api/groups/:id/members
 * @desc    Add members to group
 * @access  Private
 */
exports.addMembers = async (req, res, next) => {
  try {
    const { members } = req.body;

    const group = await ChatGroup.findById(req.params.id);

    if (!group) {
      return res.status(404).json({
        status: 'error',
        message: 'Group not found'
      });
    }

    // Check if user is a member or creator
    if (!group.members.includes(req.user._id)) {
      return res.status(403).json({
        status: 'error',
        message: 'You are not authorized to add members'
      });
    }

    // Add new members
    const newMembers = members.filter(m => !group.members.includes(m));
    group.members.push(...newMembers);
    await group.save();

    const updatedGroup = await ChatGroup.findById(group._id)
      .populate('members', 'firstname lastname email')
      .populate('createdBy', 'firstname lastname email');

    res.status(200).json({
      status: 'success',
      message: 'Members added successfully',
      group: updatedGroup
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @route   DELETE /api/groups/:id/members/:memberId
 * @desc    Remove member from group
 * @access  Private
 */
exports.removeMember = async (req, res, next) => {
  try {
    const { id, memberId } = req.params;

    const group = await ChatGroup.findById(id);

    if (!group) {
      return res.status(404).json({
        status: 'error',
        message: 'Group not found'
      });
    }

    // Check if user is the creator
    if (group.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Only group creator can remove members'
      });
    }

    // Remove member
    group.members = group.members.filter(m => m.toString() !== memberId);
    await group.save();

    const updatedGroup = await ChatGroup.findById(group._id)
      .populate('members', 'firstname lastname email')
      .populate('createdBy', 'firstname lastname email');

    res.status(200).json({
      status: 'success',
      message: 'Member removed successfully',
      group: updatedGroup
    });
  } catch (error) {
    next(error);
  }
};
