const mongoose = require('mongoose');

/**
 * ChatGroup Schema
 * Represents a group chat with multiple members
 */
const chatGroupSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Group name is required'],
    trim: true,
    maxlength: [100, 'Group name cannot exceed 100 characters']
  },
  members: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Creator is required']
  }
}, {
  timestamps: true
});

// Index for faster queries
chatGroupSchema.index({ members: 1 });
chatGroupSchema.index({ createdBy: 1 });

// Validation: Must have at least 2 members
chatGroupSchema.pre('validate', function(next) {
  if (this.members && this.members.length < 2) {
    next(new Error('Group must have at least 2 members'));
  } else {
    next();
  }
});

// Virtual for member count
chatGroupSchema.virtual('memberCount').get(function() {
  return this.members ? this.members.length : 0;
});

// Transform output
chatGroupSchema.set('toJSON', {
  virtuals: true,
  transform: function(doc, ret) {
    delete ret.__v;
    return ret;
  }
});

module.exports = mongoose.model('ChatGroup', chatGroupSchema);
