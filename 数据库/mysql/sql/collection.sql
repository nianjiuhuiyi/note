/*
 Navicat Premium Data Transfer

 Source Server         : mysql_docker
 Source Server Type    : MySQL
 Source Server Version : 80027
 Source Host           : 192.168.125.135:3306
 Source Schema         : my_areas

 Target Server Type    : MySQL
 Target Server Version : 80027
 File Encoding         : 65001

 Date: 11/04/2022 16:52:22
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for collection
-- ----------------------------
DROP TABLE IF EXISTS `collection`;
CREATE TABLE `collection`  (
  `pid` tinyint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键，自动增长',
  `district_id` tinyint(0) UNSIGNED NOT NULL,
  `district` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `level` tinyint(0) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collection
-- ----------------------------
INSERT INTO `collection` VALUES (1, 2, '北京市', 1);
INSERT INTO `collection` VALUES (20, 26, '四川省', 1);
INSERT INTO `collection` VALUES (28, 8, '贵州省', 1);
INSERT INTO `collection` VALUES (29, 5, '甘肃省', 1);

SET FOREIGN_KEY_CHECKS = 1;
