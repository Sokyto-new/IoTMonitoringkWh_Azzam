-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 10, 2026 at 07:23 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `iot_energy_monitoring`
--

-- --------------------------------------------------------

--
-- Table structure for table `alert`
--

CREATE TABLE `alert` (
  `alert_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `alert_type` enum('ENERGY_LIMIT','POWER_LIMIT','DEVICE_OFFLINE','VOLTAGE_ANOMALY','CURRENT_ANOMALY','TEMPERATURE_HIGH','SCHEDULE_FAILED','MAINTENANCE_REMINDER') NOT NULL,
  `severity` enum('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT 'MEDIUM',
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `threshold_value` decimal(12,4) DEFAULT NULL,
  `actual_value` decimal(12,4) DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `related_session_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `is_resolved` tinyint(1) DEFAULT 0,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `daily_summary`
--

CREATE TABLE `daily_summary` (
  `summary_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `summary_date` date NOT NULL,
  `total_energy_kwh` decimal(12,6) NOT NULL,
  `total_cost` decimal(12,2) NOT NULL,
  `avg_power_w` decimal(10,4) DEFAULT NULL,
  `peak_power_w` decimal(10,4) DEFAULT NULL,
  `peak_time` time DEFAULT NULL,
  `avg_voltage_v` decimal(7,3) DEFAULT NULL,
  `avg_current_a` decimal(8,4) DEFAULT NULL,
  `avg_power_factor` decimal(4,3) DEFAULT NULL,
  `operating_hours` decimal(6,2) DEFAULT NULL,
  `efficiency_score` decimal(5,2) DEFAULT NULL,
  `anomaly_count` int(11) DEFAULT 0,
  `log_count` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `device`
--

CREATE TABLE `device` (
  `device_id` int(11) NOT NULL,
  `device_name` varchar(100) NOT NULL,
  `device_code` varchar(50) NOT NULL,
  `esp32_mac` varchar(17) NOT NULL,
  `user_id` int(11) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `device_type` enum('lighting','appliance','ac','other') DEFAULT 'lighting',
  `power_rating_w` decimal(8,2) DEFAULT NULL,
  `voltage_rating_v` decimal(5,2) DEFAULT 220.00,
  `current_rating_a` decimal(5,2) DEFAULT NULL,
  `installation_date` date DEFAULT NULL,
  `warranty_until` date DEFAULT NULL,
  `is_online` tinyint(1) DEFAULT 0,
  `last_seen` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `firmware_version` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `device_command`
--

CREATE TABLE `device_command` (
  `command_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `command_type` enum('RELAY_ON','RELAY_OFF','SET_PWM','REBOOT','UPDATE_FIRMWARE','GET_STATUS') NOT NULL,
  `command_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`command_payload`)),
  `issued_by` int(11) NOT NULL,
  `issued_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `delivered_at` timestamp NULL DEFAULT NULL,
  `executed_at` timestamp NULL DEFAULT NULL,
  `status` enum('PENDING','DELIVERED','EXECUTED','FAILED','TIMEOUT') DEFAULT 'PENDING',
  `response_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_payload`)),
  `error_message` text DEFAULT NULL,
  `retry_count` int(11) DEFAULT 0,
  `next_retry` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `energy_limit`
--

CREATE TABLE `energy_limit` (
  `limit_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `daily_limit_kwh` decimal(10,3) DEFAULT 5.000,
  `weekly_limit_kwh` decimal(10,3) DEFAULT 30.000,
  `monthly_limit_kwh` decimal(10,3) DEFAULT 150.000,
  `instant_power_limit_w` decimal(10,3) DEFAULT NULL,
  `cost_per_kwh` decimal(8,2) DEFAULT 1500.00,
  `currency` char(3) DEFAULT 'IDR',
  `tariff_type` enum('RESIDENTIAL','BUSINESS','INDUSTRY') DEFAULT 'RESIDENTIAL',
  `peak_hours_start` time DEFAULT '18:00:00',
  `peak_hours_end` time DEFAULT '22:00:00',
  `peak_multiplier` decimal(4,2) DEFAULT 1.50,
  `alert_threshold` decimal(5,2) DEFAULT 80.00,
  `auto_shutdown` tinyint(1) DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance_log`
--

CREATE TABLE `maintenance_log` (
  `maintenance_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `maintenance_type` enum('ROUTINE','REPAIR','CALIBRATION','CLEANING','INSPECTION') DEFAULT 'ROUTINE',
  `performed_by` varchar(100) DEFAULT NULL,
  `performed_at` date NOT NULL,
  `next_maintenance` date DEFAULT NULL,
  `description` text NOT NULL,
  `parts_replaced` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`parts_replaced`)),
  `cost` decimal(10,2) DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `before_condition` text DEFAULT NULL,
  `after_condition` text DEFAULT NULL,
  `technician_notes` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `monitoring_log`
--

CREATE TABLE `monitoring_log` (
  `log_id` bigint(20) NOT NULL,
  `device_id` int(11) NOT NULL,
  `session_id` int(11) DEFAULT NULL,
  `timestamp` datetime(6) NOT NULL,
  `voltage_v` decimal(7,3) NOT NULL,
  `current_a` decimal(8,4) NOT NULL,
  `active_power_w` decimal(10,4) NOT NULL,
  `apparent_power_va` decimal(10,4) DEFAULT NULL,
  `reactive_power_var` decimal(10,4) DEFAULT NULL,
  `power_factor` decimal(4,3) DEFAULT NULL,
  `frequency_hz` decimal(5,2) DEFAULT NULL,
  `energy_wh` decimal(12,6) NOT NULL,
  `temperature_c` decimal(5,2) DEFAULT NULL,
  `device_status` enum('ON','OFF','STANDBY','ERROR') DEFAULT 'ON',
  `data_source` enum('SENSOR','SCHEDULE','MANUAL','AUTO') DEFAULT 'SENSOR',
  `is_anomaly` tinyint(1) DEFAULT 0,
  `anomaly_reason` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `monitoring_session`
--

CREATE TABLE `monitoring_session` (
  `session_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_name` varchar(100) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `initial_kwh` decimal(12,6) NOT NULL,
  `final_kwh` decimal(12,6) DEFAULT NULL,
  `total_duration_seconds` int(11) GENERATED ALWAYS AS (timestampdiff(SECOND,`start_time`,`end_time`)) STORED,
  `total_energy_kwh` decimal(12,6) GENERATED ALWAYS AS (case when `final_kwh` is null then NULL else `final_kwh` - `initial_kwh` end) STORED,
  `cost_per_kwh` decimal(10,2) DEFAULT 1500.00,
  `energy_cost` decimal(12,2) GENERATED ALWAYS AS (case when `final_kwh` is null then 0 else `final_kwh` - `initial_kwh` end * `cost_per_kwh`) STORED,
  `average_power_w` decimal(10,4) DEFAULT NULL,
  `peak_power_w` decimal(10,4) DEFAULT NULL,
  `status` enum('ACTIVE','COMPLETED','PAUSED','CANCELLED') DEFAULT 'ACTIVE',
  `purpose` enum('MONITORING','TESTING','AUDIT','RESEARCH') DEFAULT 'MONITORING',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `schedule_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `schedule_name` varchar(100) NOT NULL,
  `action_type` enum('TURN_ON','TURN_OFF','SET_BRIGHTNESS','SET_POWER_LIMIT') DEFAULT 'TURN_ON',
  `action_value` varchar(50) DEFAULT NULL,
  `trigger_type` enum('TIME','SUNRISE','SUNSET','ENERGY_LIMIT','TEMPERATURE') DEFAULT 'TIME',
  `trigger_value` varchar(50) DEFAULT NULL,
  `days_of_week` char(7) DEFAULT '1111111',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_recurring` tinyint(1) DEFAULT 1,
  `is_active` tinyint(1) DEFAULT 1,
  `last_executed` timestamp NULL DEFAULT NULL,
  `next_execution` timestamp NULL DEFAULT NULL,
  `execution_count` int(11) DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `role` enum('admin','user','viewer') DEFAULT 'user',
  `phone_number` varchar(20) DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `password_reset_token` varchar(100) DEFAULT NULL,
  `token_expires_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alert`
--
ALTER TABLE `alert`
  ADD PRIMARY KEY (`alert_id`),
  ADD KEY `related_session_id` (`related_session_id`),
  ADD KEY `resolved_by` (`resolved_by`),
  ADD KEY `idx_alert_device` (`device_id`,`created_at`),
  ADD KEY `idx_alert_unread` (`is_read`,`is_resolved`),
  ADD KEY `idx_alert_severity` (`severity`,`created_at`);

--
-- Indexes for table `daily_summary`
--
ALTER TABLE `daily_summary`
  ADD PRIMARY KEY (`summary_id`),
  ADD UNIQUE KEY `unique_device_date` (`device_id`,`summary_date`),
  ADD KEY `idx_summary_date` (`summary_date`),
  ADD KEY `idx_summary_device` (`device_id`,`summary_date`);

--
-- Indexes for table `device`
--
ALTER TABLE `device`
  ADD PRIMARY KEY (`device_id`),
  ADD UNIQUE KEY `device_code` (`device_code`),
  ADD UNIQUE KEY `esp32_mac` (`esp32_mac`),
  ADD KEY `idx_device_user` (`user_id`),
  ADD KEY `idx_device_online` (`is_online`),
  ADD KEY `idx_device_mac` (`esp32_mac`);

--
-- Indexes for table `device_command`
--
ALTER TABLE `device_command`
  ADD PRIMARY KEY (`command_id`),
  ADD KEY `issued_by` (`issued_by`),
  ADD KEY `idx_command_device` (`device_id`,`status`),
  ADD KEY `idx_command_pending` (`status`,`issued_at`),
  ADD KEY `idx_command_retry` (`next_retry`,`status`);

--
-- Indexes for table `energy_limit`
--
ALTER TABLE `energy_limit`
  ADD PRIMARY KEY (`limit_id`),
  ADD UNIQUE KEY `device_id` (`device_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_limit_device` (`device_id`),
  ADD KEY `idx_limit_tariff` (`tariff_type`);

--
-- Indexes for table `maintenance_log`
--
ALTER TABLE `maintenance_log`
  ADD PRIMARY KEY (`maintenance_id`),
  ADD KEY `device_id` (`device_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `monitoring_log`
--
ALTER TABLE `monitoring_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_log_device_time` (`device_id`,`timestamp`),
  ADD KEY `idx_log_timestamp` (`timestamp`),
  ADD KEY `idx_log_session` (`session_id`),
  ADD KEY `idx_log_anomaly` (`is_anomaly`);

--
-- Indexes for table `monitoring_session`
--
ALTER TABLE `monitoring_session`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `device_id` (`device_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_schedule_device` (`device_id`,`is_active`),
  ADD KEY `idx_schedule_next` (`next_execution`),
  ADD KEY `idx_schedule_trigger` (`trigger_type`,`is_active`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_user_role` (`role`),
  ADD KEY `idx_user_active` (`is_active`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alert`
--
ALTER TABLE `alert`
  MODIFY `alert_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `daily_summary`
--
ALTER TABLE `daily_summary`
  MODIFY `summary_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `device`
--
ALTER TABLE `device`
  MODIFY `device_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `device_command`
--
ALTER TABLE `device_command`
  MODIFY `command_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `energy_limit`
--
ALTER TABLE `energy_limit`
  MODIFY `limit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance_log`
--
ALTER TABLE `maintenance_log`
  MODIFY `maintenance_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `monitoring_log`
--
ALTER TABLE `monitoring_log`
  MODIFY `log_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `monitoring_session`
--
ALTER TABLE `monitoring_session`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alert`
--
ALTER TABLE `alert`
  ADD CONSTRAINT `alert_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `alert_ibfk_2` FOREIGN KEY (`related_session_id`) REFERENCES `monitoring_session` (`session_id`),
  ADD CONSTRAINT `alert_ibfk_3` FOREIGN KEY (`resolved_by`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `daily_summary`
--
ALTER TABLE `daily_summary`
  ADD CONSTRAINT `daily_summary_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE;

--
-- Constraints for table `device`
--
ALTER TABLE `device`
  ADD CONSTRAINT `device_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `device_command`
--
ALTER TABLE `device_command`
  ADD CONSTRAINT `device_command_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `device_command_ibfk_2` FOREIGN KEY (`issued_by`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `energy_limit`
--
ALTER TABLE `energy_limit`
  ADD CONSTRAINT `energy_limit_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `energy_limit_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `maintenance_log`
--
ALTER TABLE `maintenance_log`
  ADD CONSTRAINT `maintenance_log_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `maintenance_log_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `monitoring_log`
--
ALTER TABLE `monitoring_log`
  ADD CONSTRAINT `monitoring_log_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `monitoring_log_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `monitoring_session` (`session_id`) ON DELETE SET NULL;

--
-- Constraints for table `monitoring_session`
--
ALTER TABLE `monitoring_session`
  ADD CONSTRAINT `monitoring_session_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `monitoring_session_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `schedule_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `device` (`device_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedule_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
