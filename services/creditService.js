// Credit Service - Handles complex credit calculations
// This is the "brain" of the credit system

const { CreditTransaction, User } = require('../models');
const { Op } = require('sequelize');

class CreditService {
  // Award credits to a user for an activity
  async awardCredits(userId, activityType, details = {}) {
    try {
      let amount = 0;
      let description = '';
      
      // Calculate credits based on activity type
      switch(activityType) {
        case 'energy_saved':
          // 1 credit per 100 kWh saved
          amount = Math.floor(details.value / 100);
          description = `Saved ${details.value} kWh of energy`;
          break;
        
        case 'carbon_reduced':
          // 1 credit per 10 kg CO2 reduced
          amount = Math.floor(details.value / 10);
          description = `Reduced ${details.value} kg CO2`;
          break;
        
        case 'species_documented':
          // 2 credits per species
          amount = 2;
          description = `Documented species: ${details.speciesName}`;
          break;
        
        case 'peer_review':
          // Fixed 2 credits for peer review
          amount = 2;
          description = 'Completed peer review';
          break;
        
        case 'code_contribution':
          // Variable credits based on complexity
          const complexity = details.complexity || 'simple';
          amount = complexity === 'complex' ? 20 : 
                  complexity === 'medium' ? 10 : 5;
          description = `Code contribution: ${details.description}`;
          break;
        
        case 'weekly_participation':
          // 1 credit for being active this week
          amount = 1;
          description = 'Weekly participation bonus';
          break;
        
        default:
          amount = details.amount || 1;
          description = details.description || activityType;
      }
      
      if (amount > 0) {
        // Create transaction record
        const transaction = await CreditTransaction.create({
          userId,
          activityType,
          amount,
          description,
          projectId: details.projectId,
          isVerified: details.autoVerify || false
        });
        
        // Update user's total credits
        await User.increment('totalCredits', {
          by: amount,
          where: { id: userId }
        });
        
        console.log(`Awarded ${amount} credits to user ${userId}`);
        return { success: true, creditsAwarded: amount, transaction };
      }
      
      return { success: false, message: 'No credits awarded' };
      
    } catch (error) {
      console.error('Credit service error:', error);
      return { success: false, error: error.message };
    }
  }
  
  // Get leaderboard of top users
  async getLeaderboard(classType = null, limit = 10) {
    const where = classType ? { classType, role: 'student' } : { role: 'student' };
    
    return await User.findAll({
      where,
      attributes: ['id', 'firstName', 'lastName', 'classType', 'totalCredits'],
      order: [['totalCredits', 'DESC']],
      limit
    });
  }
  
  // Calculate user's rank among all students
  async getUserRank(userId) {
    const user = await User.findByPk(userId);
    const higherRanked = await User.count({
      where: {
        totalCredits: { [Op.gt]: user.totalCredits },
        role: 'student'
      }
    });
    return higherRanked + 1;
  }
  
  // Get detailed statistics for a user
  async getUserStats(userId) {
    const user = await User.findByPk(userId);
    
    // Count transactions
    const transactions = await CreditTransaction.count({ 
      where: { userId } 
    });
    
    // Calculate weekly credits
    const weekStart = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const weeklyCredits = await CreditTransaction.sum('amount', {
      where: {
        userId,
        createdAt: { [Op.gte]: weekStart }
      }
    }) || 0;
    
    // Calculate monthly credits
    const monthStart = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const monthlyCredits = await CreditTransaction.sum('amount', {
      where: {
        userId,
        createdAt: { [Op.gte]: monthStart }
      }
    }) || 0;
    
    return {
      totalCredits: user.totalCredits,
      totalTransactions: transactions,
      weeklyCredits,
      monthlyCredits,
      rank: await this.getUserRank(userId),
      averagePerWeek: Math.round(user.totalCredits / 4)  // Rough estimate
    };
  }
  
  // Check for and award streak bonuses
  async checkStreakBonus(userId) {
    // Get last 7 days of activity
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const transactions = await CreditTransaction.findAll({
      where: {
        userId,
        createdAt: { [Op.gte]: sevenDaysAgo }
      },
      attributes: ['createdAt'],
      order: [['createdAt', 'DESC']]
    });
    
    // Check if user has been active each day
    const uniqueDays = new Set();
    transactions.forEach(t => {
      const day = t.createdAt.toISOString().split('T')[0];
      uniqueDays.add(day);
    });
    
    // Award bonus for 7-day streak
    if (uniqueDays.size >= 7) {
      await this.awardCredits(userId, 'streak_bonus', {
        amount: 5,
        description: '7-day activity streak bonus!',
        autoVerify: true
      });
      return true;
    }
    
    return false;
  }
}

module.exports = new CreditService();
