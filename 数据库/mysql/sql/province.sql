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

 Date: 11/04/2022 16:52:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for province
-- ----------------------------
DROP TABLE IF EXISTS `province`;
CREATE TABLE `province`  (
  `district_id` smallint(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '自增id',
  `pid` smallint(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '父及关系',
  `district` varchar(120) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '地区名称',
  `level` tinyint(1) NOT NULL COMMENT '子属关系'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of province
-- ----------------------------
INSERT INTO `province` VALUES (2, 1, '北京市', 1);
INSERT INTO `province` VALUES (3, 1, '安徽省', 1);
INSERT INTO `province` VALUES (4, 1, '福建省', 1);
INSERT INTO `province` VALUES (5, 1, '甘肃省', 1);
INSERT INTO `province` VALUES (6, 1, '广东省', 1);
INSERT INTO `province` VALUES (7, 1, '广西壮族自治区', 1);
INSERT INTO `province` VALUES (8, 1, '贵州省', 1);
INSERT INTO `province` VALUES (9, 1, '海南省', 1);
INSERT INTO `province` VALUES (10, 1, '河北省', 1);
INSERT INTO `province` VALUES (11, 1, '河南省', 1);
INSERT INTO `province` VALUES (12, 1, '黑龙江省', 1);
INSERT INTO `province` VALUES (13, 1, '湖北省', 1);
INSERT INTO `province` VALUES (14, 1, '湖南省', 1);
INSERT INTO `province` VALUES (15, 1, '吉林省', 1);
INSERT INTO `province` VALUES (16, 1, '江苏省', 1);
INSERT INTO `province` VALUES (17, 1, '江西省', 1);
INSERT INTO `province` VALUES (18, 1, '辽宁省', 1);
INSERT INTO `province` VALUES (19, 1, '内蒙古自治区', 1);
INSERT INTO `province` VALUES (20, 1, '宁夏回族自治区', 1);
INSERT INTO `province` VALUES (21, 1, '青海省', 1);
INSERT INTO `province` VALUES (22, 1, '山东省', 1);
INSERT INTO `province` VALUES (23, 1, '山西省', 1);
INSERT INTO `province` VALUES (24, 1, '陕西省', 1);
INSERT INTO `province` VALUES (25, 1, '上海市', 1);
INSERT INTO `province` VALUES (26, 1, '四川省', 1);
INSERT INTO `province` VALUES (27, 1, '天津市', 1);
INSERT INTO `province` VALUES (28, 1, '西藏自治区', 1);
INSERT INTO `province` VALUES (29, 1, '新疆维吾尔自治区', 1);
INSERT INTO `province` VALUES (30, 1, '云南省', 1);
INSERT INTO `province` VALUES (31, 1, '浙江省', 1);
INSERT INTO `province` VALUES (32, 1, '重庆市', 1);
INSERT INTO `province` VALUES (33, 1, '香港特别行政区', 1);
INSERT INTO `province` VALUES (34, 1, '澳门特别行政区', 1);
INSERT INTO `province` VALUES (35, 1, '台湾省', 1);

SET FOREIGN_KEY_CHECKS = 1;
