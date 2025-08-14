SET NAMES utf8;
SET SQL_MODE='';
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

CREATE DATABASE IF NOT EXISTS `cm_storage` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `cm_storage`;


/* Create table `disk` */
DROP TABLE IF EXISTS `disk`;

CREATE TABLE `disk` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `uid` VARCHAR(255) NOT NULL, 
  `type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are ata,bsas,eata,fcal,lun,msata,sas,sata,scsi,ssd,xata,xsas,fsas,unknown', 
  `rpm` INT DEFAULT NULL, 
  `home_node_id` INT DEFAULT NULL, 
  `owner_node_id` INT DEFAULT NULL, 
  `model` VARCHAR(255) DEFAULT NULL, 
  `serial_number` VARCHAR(255) DEFAULT NULL, 
  `size_mb` BIGINT DEFAULT NULL, 
  `shelf` VARCHAR(255) DEFAULT NULL, 
  `shelf_bay` VARCHAR(255) DEFAULT NULL, 
  `pool` VARCHAR(255) DEFAULT NULL, 
  `vendor` VARCHAR(255) DEFAULT NULL, 
  `raid_position` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are copy,data,dparity,orphan,parity,pending,present,spare,tparity', 
  `container_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are aggregate,broken,labelmaint,maintenance,spare,unassigned,volume,unknown,foreign,unsupported', 
  `cluster_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_disk_home_node` FOREIGN KEY (`home_node_id`) REFERENCES `node` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_disk_owner_node` FOREIGN KEY (`owner_node_id`) REFERENCES `node` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_disk_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_disk_home_node` (`home_node_id`), 
  KEY `idx_cm_storage_disk_owner_node` (`owner_node_id`), 
  KEY `idx_cm_storage_disk_cluster` (`cluster_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `quota` */
DROP TABLE IF EXISTS `quota`;

CREATE TABLE `quota` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_address` VARCHAR(255) NOT NULL, 
  `cluster_name` VARCHAR(20) DEFAULT NULL, 
  `vserver_name` VARCHAR(50) NOT NULL, 
  `volume_name` VARCHAR(255) NOT NULL, 
  `name` VARCHAR(50) NOT NULL, 
  `path` VARCHAR(1024) DEFAULT NULL, 
  `disk_limit_mb` INT DEFAULT NULL, 
  `disk_used_mb` INT DEFAULT NULL, 
  `volume_used_pct` INT DEFAULT NULL, 
  `used_pct` INT DEFAULT NULL, 
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  UNIQUE KEY `uk_cm_storage_quota_natural_key` (`cluster_address`,`vserver_name`,`volume_name`,`name`,`timestamp`),
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `quota_extend` */
DROP TABLE IF EXISTS `quota_extend`;

CREATE TABLE `quota_extend` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_address` VARCHAR(255) DEFAULT NULL, 
  `cluster_name` VARCHAR(255) DEFAULT NULL, 
  `vserver_name` VARCHAR(255) DEFAULT NULL, 
  `volume_name` VARCHAR(255) DEFAULT NULL, 
  `name` VARCHAR(255) DEFAULT NULL, 
  `path` VARCHAR(255) DEFAULT NULL, 
  `disk_limit_mb` INT DEFAULT NULL, 
  `disk_used_mb` INT DEFAULT NULL, 
  `used_pct` INT DEFAULT NULL, 
  `volume_used_pct` INT DEFAULT NULL, 
  `new_disk_limit_mb` INT DEFAULT NULL, 
  `extensions_last_2_days` INT DEFAULT NULL, 
  `extensions_last_5_days` INT DEFAULT NULL, 
  `extensions` VARCHAR(10) DEFAULT NULL, 
  `volume_capacity` VARCHAR(10) DEFAULT NULL, 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cifs_session` */
DROP TABLE IF EXISTS `cifs_session`;

CREATE TABLE `cifs_session` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_name` VARCHAR(20) NOT NULL, 
  `vserver_name` VARCHAR(50) NOT NULL, 
  `windows_user` VARCHAR(255) NOT NULL, 
  `user_type` VARCHAR(20) NOT NULL, 
  `address` VARCHAR(20) NOT NULL, 
  `protocol_version` VARCHAR(20) NOT NULL, 
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `vscan_connection` */
DROP TABLE IF EXISTS `vscan_connection`;

CREATE TABLE `vscan_connection` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_name` VARCHAR(20) NOT NULL, 
  `vserver_name` VARCHAR(50) NOT NULL, 
  `server_status` VARCHAR(50) NOT NULL, 
  `server` VARCHAR(255) NOT NULL, 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cluster_image` */
DROP TABLE IF EXISTS `cluster_image`;

CREATE TABLE `cluster_image` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_name` VARCHAR(20) NOT NULL, 
  `version` VARCHAR(50) NOT NULL, 
  `current_release` VARCHAR(50) NOT NULL, 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cluster_extended` */
DROP TABLE IF EXISTS `cluster_extended`;

CREATE TABLE `cluster_extended` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_name` VARCHAR(255) NOT NULL, 
  `current_release` VARCHAR(50) NOT NULL, 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `aggregate` */
DROP TABLE IF EXISTS `aggregate`;

CREATE TABLE `aggregate` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `node_id` INT NOT NULL, 
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `size_mb` BIGINT NOT NULL, 
  `used_size_mb` BIGINT NOT NULL, 
  `available_size_mb` BIGINT NOT NULL, 
  `raid_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are raid_dp,raid4,raid0,raid_tec', 
  `raid_status` VARCHAR(128) NOT NULL, 
  `block_type` VARCHAR(255) NOT NULL COMMENT 'possible values are 32-bit,64-bit', 
  `state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are offline,online,restricted,creating,destroying,failed,frozen,inconsistent,iron_restricted,mounting,partial,quiesced,quiescing,reverted,unknown,unmounted,unmounting', 
  `number_of_disks` INT NOT NULL, 
  `volume_count` INT NOT NULL, 
  `is_hybrid` BOOL DEFAULT NULL, 
  `hybrid_enabled` BOOL DEFAULT NULL, 
  `hybrid_cache_size_mb` BIGINT DEFAULT NULL, 
  `snapshot_total_size_mb` BIGINT DEFAULT NULL, 
  `snapshot_used_size_mb` BIGINT DEFAULT NULL, 
  `has_local_root` BOOL DEFAULT NULL, 
  `has_partner_root` BOOL DEFAULT NULL, 
  `daily_growth_rate_mb` BIGINT DEFAULT NULL, 
  `days_until_full` BIGINT DEFAULT NULL, 
  `snaplock_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are non-snaplock,compliance,enterprise', 
  `is_snaplock` BOOL DEFAULT NULL, 
  `type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are ssd,hdd,vmdisk,lun,hybrid', 
  `is_composite` BOOL DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_aggregate_node` FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_aggregate_node` (`node_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `aggregate_object_store_mapping` */
DROP TABLE IF EXISTS `aggregate_object_store_mapping`;

CREATE TABLE `aggregate_object_store_mapping` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `object_store_id` INT NOT NULL, 
  `aggregate_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_aggregate_object_store_mapping_object_store` FOREIGN KEY (`object_store_id`) REFERENCES `object_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_aggregate_object_store_mapping_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_aggregate_object_store_mapping_object_store` (`object_store_id`), 
  KEY `idx_cm_storage_aggregate_object_store_mapping_aggregate` (`aggregate_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `annotation` */
DROP TABLE IF EXISTS `annotation`;

CREATE TABLE `annotation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `value` VARCHAR(255) NOT NULL, 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `broadcast_domain` */
DROP TABLE IF EXISTS `broadcast_domain`;

CREATE TABLE `broadcast_domain` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `ipspace_id` INT NOT NULL, 
  `mtu` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_broadcast_domain_ipspace` FOREIGN KEY (`ipspace_id`) REFERENCES `ipspace` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_broadcast_domain_ipspace` (`ipspace_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cifs_share` */
DROP TABLE IF EXISTS `cifs_share`;

CREATE TABLE `cifs_share` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `path` VARCHAR(255) DEFAULT NULL, 
  `vserver_id` INT NOT NULL, 
  `comment` VARCHAR(255) DEFAULT NULL, 
  `share_properties` VARCHAR(255) DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_cifs_share_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_cifs_share_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cifs_share_acl` */
DROP TABLE IF EXISTS `cifs_share_acl`;

CREATE TABLE `cifs_share_acl` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cifs_share_id` INT NOT NULL, 
  `user_or_group` VARCHAR(255) NOT NULL, 
  `access_level` VARCHAR(255) NOT NULL COMMENT 'possible values are no_access,read,change,full_control', 
  CONSTRAINT `fk_cm_storage_cifs_share_acl_cifs_share` FOREIGN KEY (`cifs_share_id`) REFERENCES `cifs_share` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_cifs_share_acl_cifs_share` (`cifs_share_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cluster` */
DROP TABLE IF EXISTS `cluster`;

CREATE TABLE `cluster` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `admin_vserver_id` INT DEFAULT NULL, 
  `name` VARCHAR(255) NOT NULL, 
  `location` VARCHAR(255) DEFAULT NULL, 
  `primary_address` VARCHAR(64) NOT NULL, 
  `uuid` VARCHAR(64) DEFAULT NULL, 
  `serial_number` VARCHAR(255) DEFAULT NULL, 
  `version` VARCHAR(255) DEFAULT NULL, 
  `is_metrocluster` BOOL DEFAULT NULL, 
  `mt_configuration_state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are unknown,not_reachable,not_configured,configuration_error,partially_configured,configured', 
  `mt_mode` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are unknown,not_reachable,not_configured,normal,switchover,waiting_for_switchback,partial_switchover,partial_switchback', 
  UNIQUE KEY `uk_cm_storage_cluster_natural_key` (`primary_address`),
  CONSTRAINT `fk_cm_storage_cluster_admin_vserver` FOREIGN KEY (`admin_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_cluster_admin_vserver` (`admin_vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cluster_annotation` */
DROP TABLE IF EXISTS `cluster_annotation`;

CREATE TABLE `cluster_annotation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_id` INT NOT NULL, 
  `annotation_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_cluster_annotation_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_cluster_annotation_annotation` FOREIGN KEY (`annotation_id`) REFERENCES `annotation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_cluster_annotation_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_cluster_annotation_annotation` (`annotation_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cluster_license` */
DROP TABLE IF EXISTS `cluster_license`;

CREATE TABLE `cluster_license` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_id` INT NOT NULL, 
  `license` VARCHAR(100) NOT NULL, 
  CONSTRAINT `fk_cm_storage_cluster_license_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_cluster_license_cluster` (`cluster_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `cluster_peer` */
DROP TABLE IF EXISTS `cluster_peer`;

CREATE TABLE `cluster_peer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `primary_cluster_id` INT NOT NULL, 
  `peer_cluster_id` INT NOT NULL, 
  `cluster_uuid` VARCHAR(64) DEFAULT NULL, 
  `peer_addresses` VARCHAR(1024) DEFAULT NULL, 
  `availability` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are unavailable,available,partial,pending', 
  `active_addresses` VARCHAR(1024) DEFAULT NULL, 
  `serial_number` VARCHAR(255) DEFAULT NULL, 
  `remote_cluster_nodes` VARCHAR(1024) DEFAULT NULL, 
  `is_cluster_healthy` BOOL DEFAULT NULL, 
  `unreachable_local_nodes` VARCHAR(1024) DEFAULT NULL, 
  `address_family` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are ipv4,ipv6', 
  `auth_status_admin` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are use-authentication', 
  `auth_status_operational` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are ok,absent,pending,expired,revoked,declined,refused,ok_and_offer,absent_but_offer,revoked_but_offer,intent_mismatch,key_mismatch,incapable', 
  `ipspace_id` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_cluster_peer_primary_cluster` FOREIGN KEY (`primary_cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_cluster_peer_peer_cluster` FOREIGN KEY (`peer_cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_cluster_peer_ipspace` FOREIGN KEY (`ipspace_id`) REFERENCES `ipspace` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_cluster_peer_primary_cluster` (`primary_cluster_id`), 
  KEY `idx_cm_storage_cluster_peer_peer_cluster` (`peer_cluster_id`), 
  KEY `idx_cm_storage_cluster_peer_ipspace` (`ipspace_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `disk_aggregate` */
DROP TABLE IF EXISTS `disk_aggregate`;

CREATE TABLE `disk_aggregate` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `disk_id` INT NOT NULL, 
  `aggregate_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_disk_aggregate_disk` FOREIGN KEY (`disk_id`) REFERENCES `disk` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_disk_aggregate_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_disk_aggregate_disk` (`disk_id`), 
  KEY `idx_cm_storage_disk_aggregate_aggregate` (`aggregate_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `efficiency_policy` */
DROP TABLE IF EXISTS `efficiency_policy`;

CREATE TABLE `efficiency_policy` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `vserver_id` INT NOT NULL, 
  `schedule_id` INT DEFAULT NULL, 
  `enabled` BOOL NOT NULL, 
  `comment` VARCHAR(255) DEFAULT NULL, 
  `duration` INT DEFAULT NULL, 
  `qos_policy` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are background,best_effort', 
  CONSTRAINT `fk_cm_storage_efficiency_policy_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_efficiency_policy_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_efficiency_policy_vserver` (`vserver_id`), 
  KEY `idx_cm_storage_efficiency_policy_schedule` (`schedule_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `export_policy` */
DROP TABLE IF EXISTS `export_policy`;

CREATE TABLE `export_policy` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `vserver_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_export_policy_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_export_policy_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `export_rule` */
DROP TABLE IF EXISTS `export_rule`;

CREATE TABLE `export_rule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `clientmatch` VARCHAR(255) NOT NULL, 
  `policy_id` INT NOT NULL, 
  `protocol` VARCHAR(255) NOT NULL, 
  `ro_rule` VARCHAR(255) DEFAULT NULL, 
  `rule_index` INT NOT NULL, 
  `rw_rule` VARCHAR(255) DEFAULT NULL, 
  `super_user` VARCHAR(255) DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_export_rule_policy` FOREIGN KEY (`policy_id`) REFERENCES `export_policy` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_export_rule_policy` (`policy_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `failover_group` */
DROP TABLE IF EXISTS `failover_group`;

CREATE TABLE `failover_group` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `cluster_id` INT NOT NULL, 
  `broadcast_domain_id` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_failover_group_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_failover_group_broadcast_domain` FOREIGN KEY (`broadcast_domain_id`) REFERENCES `broadcast_domain` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_failover_group_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_failover_group_broadcast_domain` (`broadcast_domain_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `fcp_adapter` */
DROP TABLE IF EXISTS `fcp_adapter`;

CREATE TABLE `fcp_adapter` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `world_wide_node_name` VARCHAR(255) DEFAULT NULL, 
  `world_wide_port_name` VARCHAR(255) DEFAULT NULL, 
  `max_speed` INT DEFAULT NULL, 
  `physical_protocol` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are fibre_channel,ethernet', 
  `media_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are auto,ptp,loop', 
  `switch_port` VARCHAR(255) DEFAULT NULL, 
  `status` VARCHAR(255) DEFAULT NULL, 
  `node_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_fcp_adapter_node` FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_fcp_adapter_node` (`node_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `igroup` */
DROP TABLE IF EXISTS `igroup`;

CREATE TABLE `igroup` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `initiators` VARCHAR(1024) DEFAULT NULL, 
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `os_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are solaris,windows,hpux,xen,aix,linux,netware,vmware,openvms,hyper_v,default', 
  `portset_id` INT DEFAULT NULL, 
  `protocol` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are fcp,iscsi,mixed', 
  `vserver_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_igroup_portset` FOREIGN KEY (`portset_id`) REFERENCES `portset` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_igroup_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_igroup_portset` (`portset_id`), 
  KEY `idx_cm_storage_igroup_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `ipspace` */
DROP TABLE IF EXISTS `ipspace`;

CREATE TABLE `ipspace` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `cluster_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_ipspace_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_ipspace_cluster` (`cluster_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `logical_interface` */
DROP TABLE IF EXISTS `logical_interface`;

CREATE TABLE `logical_interface` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `vserver_id` INT NOT NULL, 
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `role` VARCHAR(255) NOT NULL COMMENT 'possible values are cluster,data,node-mgmt,intercluster,cluster-mgmt', 
  `home_port_id` INT DEFAULT NULL, 
  `current_port_id` INT DEFAULT NULL, 
  `status` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are up,down,unknown', 
  `address` VARCHAR(64) DEFAULT NULL, 
  `netmask` VARCHAR(64) DEFAULT NULL, 
  `protocols` VARCHAR(255) DEFAULT NULL, 
  `failover_group` VARCHAR(255) DEFAULT NULL, 
  `failover_policy` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are nextavail,priority,disabled,system-defined,local-only,sfo-partner-only,broadcast-domain-wide', 
  `fcp_adapter_id` INT DEFAULT NULL, 
  `netmask_length` INT DEFAULT NULL, 
  `is_dns_update_enabled` BOOL DEFAULT NULL, 
  `listen_for_dns_query` BOOL DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_logical_interface_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_logical_interface_home_port` FOREIGN KEY (`home_port_id`) REFERENCES `port` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_logical_interface_current_port` FOREIGN KEY (`current_port_id`) REFERENCES `port` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_logical_interface_fcp_adapter` FOREIGN KEY (`fcp_adapter_id`) REFERENCES `fcp_adapter` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_logical_interface_vserver` (`vserver_id`), 
  KEY `idx_cm_storage_logical_interface_home_port` (`home_port_id`), 
  KEY `idx_cm_storage_logical_interface_current_port` (`current_port_id`), 
  KEY `idx_cm_storage_logical_interface_fcp_adapter` (`fcp_adapter_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `lun` */
DROP TABLE IF EXISTS `lun`;

CREATE TABLE `lun` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `os_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are solaris,windows,hpux,xen,aix,linux,netware,vmware,openvms,hyper_v,image,solaris_efi,windows_2008,windows_gpt', 
  `prefix_size` BIGINT DEFAULT NULL, 
  `size_mb` BIGINT NOT NULL, 
  `space_reserved` BOOL NOT NULL, 
  `qtree_id` INT DEFAULT NULL, 
  `volume_id` INT NOT NULL, 
  `vserver_id` INT NOT NULL, 
  `full_path` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `is_online` BOOL NOT NULL, 
  `space_alloc_enabled` BOOL DEFAULT NULL, 
  `serial_number` VARCHAR(255) DEFAULT NULL, 
  `alignment` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are aligned,misaligned,probably_misaligned,indeterminate', 
  `comment` VARCHAR(255) DEFAULT NULL, 
  `qos_policy_group_id` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_lun_qtree` FOREIGN KEY (`qtree_id`) REFERENCES `qtree` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_lun_volume` FOREIGN KEY (`volume_id`) REFERENCES `volume` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_lun_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_lun_qos_policy_group` FOREIGN KEY (`qos_policy_group_id`) REFERENCES `qos_policy_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_lun_qtree` (`qtree_id`), 
  KEY `idx_cm_storage_lun_volume` (`volume_id`), 
  KEY `idx_cm_storage_lun_vserver` (`vserver_id`), 
  KEY `idx_cm_storage_lun_qos_policy_group` (`qos_policy_group_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `lunmap` */
DROP TABLE IF EXISTS `lunmap`;

CREATE TABLE `lunmap` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `lun_id` INT NOT NULL, 
  `igroup_id` INT NOT NULL, 
  `lun_map_value` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_lunmap_lun` FOREIGN KEY (`lun_id`) REFERENCES `lun` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_lunmap_igroup` FOREIGN KEY (`igroup_id`) REFERENCES `igroup` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_lunmap_lun` (`lun_id`), 
  KEY `idx_cm_storage_lunmap_igroup` (`igroup_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `node` */
DROP TABLE IF EXISTS `node`;

CREATE TABLE `node` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_id` INT NOT NULL, 
  `ha_partner_id` INT DEFAULT NULL, 
  `node_vserver_id` INT DEFAULT NULL, 
  `name` VARCHAR(255) NOT NULL, 
  `primary_address` VARCHAR(64) DEFAULT NULL, 
  `model` VARCHAR(255) DEFAULT NULL, 
  `serial_number` VARCHAR(255) DEFAULT NULL, 
  `system_id` VARCHAR(64) DEFAULT NULL, 
  `os_version` VARCHAR(255) DEFAULT NULL, 
  `owner` VARCHAR(255) DEFAULT NULL, 
  `location` VARCHAR(255) DEFAULT NULL, 
  `product_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are v-series,gateway', 
  `failover_enabled` BOOL DEFAULT NULL, 
  `takeover_possible` BOOL DEFAULT NULL, 
  `failover_state` VARCHAR(255) DEFAULT NULL, 
  `memory_size_mb` BIGINT DEFAULT NULL, 
  `flash_device_count` INT DEFAULT NULL, 
  `is_flash_optimized` BOOL DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_node_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_node_ha_partner` FOREIGN KEY (`ha_partner_id`) REFERENCES `node` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_node_node_vserver` FOREIGN KEY (`node_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_node_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_node_ha_partner` (`ha_partner_id`), 
  KEY `idx_cm_storage_node_node_vserver` (`node_vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `object_store` */
DROP TABLE IF EXISTS `object_store`;

CREATE TABLE `object_store` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_id` INT NOT NULL, 
  `name` VARCHAR(255) NOT NULL, 
  `container_name` VARCHAR(255) NOT NULL, 
  `provider_type` VARCHAR(255) NOT NULL, 
  `server` VARCHAR(255) NOT NULL, 
  `is_ssl_enabled` BOOL NOT NULL, 
  `ipspace_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_object_store_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_object_store_ipspace` FOREIGN KEY (`ipspace_id`) REFERENCES `ipspace` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_object_store_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_object_store_ipspace` (`ipspace_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `port` */
DROP TABLE IF EXISTS `port`;

CREATE TABLE `port` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `node_id` INT NOT NULL, 
  `type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are physical,if_group,vlan,unknown', 
  `role` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are data,cluster,node-mgmt,intercluster,undef,cluster-mgmt,unknown', 
  `operational_status` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are up,down,unknown', 
  `mtu` INT DEFAULT NULL, 
  `ifgrp_port_id` INT DEFAULT NULL, 
  `operational_speed` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are auto,megabit_10,megabit_100,gigabit_1,gigabit_10', 
  `vlan_id` INT DEFAULT NULL, 
  `vlan_port_id` INT DEFAULT NULL, 
  `broadcast_domain_id` INT DEFAULT NULL, 
  `health_status` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are healthy,degraded', 
  `ignore_health_status` BOOL DEFAULT NULL, 
  `health_degraded_reasons` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are l2-reachability,link-flapping', 
  CONSTRAINT `fk_cm_storage_port_node` FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_port_ifgrp_port` FOREIGN KEY (`ifgrp_port_id`) REFERENCES `port` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_port_vlan_port` FOREIGN KEY (`vlan_port_id`) REFERENCES `port` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_port_broadcast_domain` FOREIGN KEY (`broadcast_domain_id`) REFERENCES `broadcast_domain` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_port_node` (`node_id`), 
  KEY `idx_cm_storage_port_ifgrp_port` (`ifgrp_port_id`), 
  KEY `idx_cm_storage_port_vlan_port` (`vlan_port_id`), 
  KEY `idx_cm_storage_port_broadcast_domain` (`broadcast_domain_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `portset` */
DROP TABLE IF EXISTS `portset`;

CREATE TABLE `portset` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `type` VARCHAR(255) NOT NULL COMMENT 'possible values are fcp,iscsi,mixed', 
  `vserver_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_portset_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_portset_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `portset_member` */
DROP TABLE IF EXISTS `portset_member`;

CREATE TABLE `portset_member` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `portset_id` INT NOT NULL, 
  `logical_interface_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_portset_member_portset` FOREIGN KEY (`portset_id`) REFERENCES `portset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_portset_member_logical_interface` FOREIGN KEY (`logical_interface_id`) REFERENCES `logical_interface` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_portset_member_portset` (`portset_id`), 
  KEY `idx_cm_storage_portset_member_logical_interface` (`logical_interface_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `qos_policy_group` */
DROP TABLE IF EXISTS `qos_policy_group`;

CREATE TABLE `qos_policy_group` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `vserver_id` INT NOT NULL, 
  `class` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are preset,user_defined,system_defined,null', 
  `max_throughput_limit` VARCHAR(255) DEFAULT NULL, 
  `min_throughput_limit` VARCHAR(255) DEFAULT NULL, 
  `isadaptive` INT DEFAULT NULL, 
  `min_iops_allocation` VARCHAR(255) DEFAULT NULL, 
  `peak_iops_allocation` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are used-space,allocated-space', 
  `is_shared` BOOL DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_qos_policy_group_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_qos_policy_group_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `qtree` */
DROP TABLE IF EXISTS `qtree`;

CREATE TABLE `qtree` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `oplock_mode` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are enabled,disabled', 
  `path` VARCHAR(512) DEFAULT NULL, 
  `security_style` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are unix,ntfs,mixed', 
  `volume_id` INT NOT NULL, 
  `disk_limit_mb` BIGINT DEFAULT NULL, 
  `disk_soft_limit_mb` BIGINT DEFAULT NULL, 
  `files_limit` BIGINT DEFAULT NULL, 
  `soft_files_limit` BIGINT DEFAULT NULL, 
  `threshold_mb` BIGINT DEFAULT NULL, 
  `disk_used_mb` BIGINT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_qtree_volume` FOREIGN KEY (`volume_id`) REFERENCES `volume` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_qtree_volume` (`volume_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `resource_group` */
DROP TABLE IF EXISTS `resource_group`;

CREATE TABLE `resource_group` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `dfm_name` VARCHAR(255) NOT NULL, 
  `name` VARCHAR(255) NOT NULL, 
  `parent_group_id` INT DEFAULT NULL, 
  `uuid` VARCHAR(255) NOT NULL, 
  UNIQUE KEY `uk_cm_storage_resource_group_natural_key` (`uuid`),
  CONSTRAINT `fk_cm_storage_resource_group_parent_group` FOREIGN KEY (`parent_group_id`) REFERENCES `resource_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_resource_group_parent_group` (`parent_group_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `resource_group_member` */
DROP TABLE IF EXISTS `resource_group_member`;

CREATE TABLE `resource_group_member` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `aggregate_id` INT DEFAULT NULL, 
  `cluster_id` INT DEFAULT NULL, 
  `group_id` INT NOT NULL, 
  `uuid` VARCHAR(255) NOT NULL, 
  `volume_id` INT DEFAULT NULL, 
  `vserver_id` INT DEFAULT NULL, 
  UNIQUE KEY `uk_cm_storage_resource_group_member_natural_key` (`uuid`),
  CONSTRAINT `fk_cm_storage_resource_group_member_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_resource_group_member_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_resource_group_member_group` FOREIGN KEY (`group_id`) REFERENCES `resource_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_resource_group_member_volume` FOREIGN KEY (`volume_id`) REFERENCES `volume` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_resource_group_member_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_resource_group_member_aggregate` (`aggregate_id`), 
  KEY `idx_cm_storage_resource_group_member_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_resource_group_member_group` (`group_id`), 
  KEY `idx_cm_storage_resource_group_member_volume` (`volume_id`), 
  KEY `idx_cm_storage_resource_group_member_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `resource_pool` */
DROP TABLE IF EXISTS `resource_pool`;

CREATE TABLE `resource_pool` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `description` VARCHAR(10240) DEFAULT NULL, 
  `uuid` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  UNIQUE KEY `uk_cm_storage_resource_pool_natural_key` (`uuid`),
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `resource_pool_member` */
DROP TABLE IF EXISTS `resource_pool_member`;

CREATE TABLE `resource_pool_member` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `resource_pool_id` INT NOT NULL, 
  `aggregate_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_resource_pool_member_resource_pool` FOREIGN KEY (`resource_pool_id`) REFERENCES `resource_pool` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_resource_pool_member_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_resource_pool_member_resource_pool` (`resource_pool_id`), 
  KEY `idx_cm_storage_resource_pool_member_aggregate` (`aggregate_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `schedule` */
DROP TABLE IF EXISTS `schedule`;

CREATE TABLE `schedule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `cluster_id` INT NOT NULL, 
  `description` VARCHAR(255) DEFAULT NULL, 
  `type` VARCHAR(255) NOT NULL COMMENT 'possible values are cron,interval', 
  `cron_days_of_month` VARCHAR(255) DEFAULT NULL, 
  `cron_days_of_week` VARCHAR(255) DEFAULT NULL, 
  `cron_hours` VARCHAR(255) DEFAULT NULL, 
  `cron_minutes` VARCHAR(255) DEFAULT NULL, 
  `cron_months` VARCHAR(255) DEFAULT NULL, 
  `interval_days` INT DEFAULT NULL, 
  `interval_hours` INT DEFAULT NULL, 
  `interval_minutes` INT DEFAULT NULL, 
  `interval_seconds` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_schedule_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_schedule_cluster` (`cluster_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `snapmirror` */
DROP TABLE IF EXISTS `snapmirror`;

CREATE TABLE `snapmirror` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `secondary_volume_id` INT NOT NULL, 
  `tries` INT DEFAULT NULL, 
  `type` VARCHAR(255) NOT NULL COMMENT 'possible values are data_protection,load_sharing,vault,transition_data_protection', 
  `volume_id` INT NOT NULL, 
  `max_transfer_rate` BIGINT DEFAULT NULL, 
  `snapmirror_policy_id` INT DEFAULT NULL, 
  `schedule_id` INT DEFAULT NULL, 
  `state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are uninitialized,snapmirrored,broken_off', 
  `relationship_identifier` VARCHAR(255) DEFAULT NULL, 
  `mirror_state` VARCHAR(255) DEFAULT NULL, 
  `relationship_status` VARCHAR(255) DEFAULT NULL, 
  `lag_time` INT DEFAULT NULL, 
  `policy_type` VARCHAR(255) DEFAULT NULL, 
  `relationship_type` VARCHAR(255) DEFAULT NULL, 
  `vserver_snapmirror_id` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_snapmirror_secondary_volume` FOREIGN KEY (`secondary_volume_id`) REFERENCES `volume` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_volume` FOREIGN KEY (`volume_id`) REFERENCES `volume` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_snapmirror_policy` FOREIGN KEY (`snapmirror_policy_id`) REFERENCES `snapmirror_policy` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_vserver_snapmirror` FOREIGN KEY (`vserver_snapmirror_id`) REFERENCES `snapmirror_svm` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_snapmirror_secondary_volume` (`secondary_volume_id`), 
  KEY `idx_cm_storage_snapmirror_volume` (`volume_id`), 
  KEY `idx_cm_storage_snapmirror_snapmirror_policy` (`snapmirror_policy_id`), 
  KEY `idx_cm_storage_snapmirror_schedule` (`schedule_id`), 
  KEY `idx_cm_storage_snapmirror_vserver_snapmirror` (`vserver_snapmirror_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `snapmirror_policy` */
DROP TABLE IF EXISTS `snapmirror_policy`;

CREATE TABLE `snapmirror_policy` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `vserver_id` INT NOT NULL, 
  `comment` VARCHAR(255) DEFAULT NULL, 
  `transfer_priority` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are normal,low', 
  `restart` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are always,never,default', 
  `tries` VARCHAR(255) DEFAULT NULL, 
  `ignore_atime` BOOL DEFAULT NULL, 
  `type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are vault,async-mirror,mirror-vault', 
  CONSTRAINT `fk_cm_storage_snapmirror_policy_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_snapmirror_policy_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `snapmirror_policy_rule` */
DROP TABLE IF EXISTS `snapmirror_policy_rule`;

CREATE TABLE `snapmirror_policy_rule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `snapmirror_label` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `snapmirror_policy_id` INT NOT NULL, 
  `keep` INT DEFAULT NULL, 
  `preserve` BOOL DEFAULT NULL, 
  `warn` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_snapmirror_policy_rule_snapmirror_policy` FOREIGN KEY (`snapmirror_policy_id`) REFERENCES `snapmirror_policy` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_snapmirror_policy_rule_snapmirror_policy` (`snapmirror_policy_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `snapmirror_svm` */
DROP TABLE IF EXISTS `snapmirror_svm`;

CREATE TABLE `snapmirror_svm` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `tries` INT DEFAULT NULL, 
  `type` VARCHAR(255) NOT NULL COMMENT 'possible values are data_protection,load_sharing,vault,transition_data_protection', 
  `destination_vserver_id` INT NOT NULL, 
  `max_transfer_rate` BIGINT DEFAULT NULL, 
  `snapmirror_policy_id` INT DEFAULT NULL, 
  `schedule_id` INT DEFAULT NULL, 
  `state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are uninitialized,snapmirrored,broken_off', 
  `relationship_identifier` VARCHAR(255) DEFAULT NULL, 
  `source_vserver_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_snapmirror_svm_destination_vserver` FOREIGN KEY (`destination_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_svm_snapmirror_policy` FOREIGN KEY (`snapmirror_policy_id`) REFERENCES `snapmirror_policy` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_svm_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapmirror_svm_source_vserver` FOREIGN KEY (`source_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_snapmirror_svm_destination_vserver` (`destination_vserver_id`), 
  KEY `idx_cm_storage_snapmirror_svm_snapmirror_policy` (`snapmirror_policy_id`), 
  KEY `idx_cm_storage_snapmirror_svm_schedule` (`schedule_id`), 
  KEY `idx_cm_storage_snapmirror_svm_source_vserver` (`source_vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `snapshot_policy` */
DROP TABLE IF EXISTS `snapshot_policy`;

CREATE TABLE `snapshot_policy` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_id` INT NOT NULL, 
  `vserver_id` INT NOT NULL, 
  `comment` VARCHAR(255) DEFAULT NULL, 
  `enabled` BOOL NOT NULL, 
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  CONSTRAINT `fk_cm_storage_snapshot_policy_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapshot_policy_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_snapshot_policy_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_snapshot_policy_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `snapshot_policy_schedule` */
DROP TABLE IF EXISTS `snapshot_policy_schedule`;

CREATE TABLE `snapshot_policy_schedule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `schedule_id` INT NOT NULL, 
  `snapshot_count` INT NOT NULL, 
  `snapshot_prefix` VARCHAR(255) DEFAULT NULL, 
  `snapmirror_label` VARCHAR(255) DEFAULT NULL, 
  `snapshot_policy_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_snapshot_policy_schedule_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_snapshot_policy_schedule_snapshot_policy` FOREIGN KEY (`snapshot_policy_id`) REFERENCES `snapshot_policy` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_snapshot_policy_schedule_schedule` (`schedule_id`), 
  KEY `idx_cm_storage_snapshot_policy_schedule_snapshot_policy` (`snapshot_policy_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `storage_pool` */
DROP TABLE IF EXISTS `storage_pool`;

CREATE TABLE `storage_pool` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL, 
  `cluster_id` INT NOT NULL, 
  `allocation_unit_size_mb` BIGINT NOT NULL, 
  `pool_usable_size_mb` BIGINT DEFAULT NULL, 
  `pool_total_size_mb` BIGINT DEFAULT NULL, 
  `storage_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are ata,bsas,fcal,fsas,lun,msata,sas,sata,ssd', 
  `disk_count` BIGINT NOT NULL, 
  CONSTRAINT `fk_cm_storage_storage_pool_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_storage_pool_cluster` (`cluster_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `storage_pool_aggregate` */
DROP TABLE IF EXISTS `storage_pool_aggregate`;

CREATE TABLE `storage_pool_aggregate` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `storage_pool_id` INT NOT NULL, 
  `aggregate_id` INT NOT NULL, 
  `used_capacity_mb` BIGINT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_storage_pool_aggregate_storage_pool` FOREIGN KEY (`storage_pool_id`) REFERENCES `storage_pool` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_storage_pool_aggregate_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_storage_pool_aggregate_storage_pool` (`storage_pool_id`), 
  KEY `idx_cm_storage_storage_pool_aggregate_aggregate` (`aggregate_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `storage_pool_available` */
DROP TABLE IF EXISTS `storage_pool_available`;

CREATE TABLE `storage_pool_available` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `storage_pool_id` INT NOT NULL, 
  `node_id` INT NOT NULL, 
  `allocation_unit_count` BIGINT NOT NULL, 
  `available_size_mb` BIGINT NOT NULL, 
  CONSTRAINT `fk_cm_storage_storage_pool_available_storage_pool` FOREIGN KEY (`storage_pool_id`) REFERENCES `storage_pool` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_storage_pool_available_node` FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_storage_pool_available_storage_pool` (`storage_pool_id`), 
  KEY `idx_cm_storage_storage_pool_available_node` (`node_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `volume` */
DROP TABLE IF EXISTS `volume`;

CREATE TABLE `volume` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `vserver_id` INT NOT NULL, 
  `aggregate_id` INT DEFAULT NULL, 
  `parent_volume_id` INT DEFAULT NULL, 
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `size_mb` BIGINT NOT NULL, 
  `used_size_mb` BIGINT NOT NULL, 
  `available_size_mb` BIGINT NOT NULL, 
  `type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are rw,ls,dp,dc', 
  `state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are online,restricted,offline', 
  `junction_path` VARCHAR(512) DEFAULT NULL, 
  `space_guarantee` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are none,volume,file', 
  `snapshot_used_mb` BIGINT NOT NULL, 
  `snapshot_reserved_percent` INT NOT NULL, 
  `snapshot_enabled` BOOL NOT NULL, 
  `style` VARCHAR(255) NOT NULL COMMENT 'possible values are flex,trad,infinivol,constituent,striped,flexgroup', 
  `max_autosize_mb` BIGINT DEFAULT NULL, 
  `block_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are 32-bit,64-bit', 
  `security_style` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are unix,ntfs,mixed,unified', 
  `dedupe_enabled` BOOL DEFAULT NULL, 
  `auto_increment_size_mb` BIGINT DEFAULT NULL, 
  `snapshot_policy_id` INT DEFAULT NULL, 
  `export_policy_id` INT DEFAULT NULL, 
  `autosize_enabled` BOOL DEFAULT NULL, 
  `compression` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are disabled,background,inline', 
  `deduplication_space_saved_mb` BIGINT DEFAULT NULL, 
  `compression_space_saved_mb` BIGINT DEFAULT NULL, 
  `percent_deduplication_space_saved` INT DEFAULT NULL, 
  `percent_compression_space_saved` INT DEFAULT NULL, 
  `hybrid_cache_eligibility` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are read,read_write', 
  `inode_files_total` BIGINT DEFAULT NULL, 
  `inode_files_used` BIGINT DEFAULT NULL, 
  `auto_size_mode` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are off,grow,grow_shrink', 
  `sis_last_op_begin_timestamp` DATETIME DEFAULT NULL, 
  `sis_last_op_end_timestamp` DATETIME DEFAULT NULL, 
  `flexcache_origin_volume_id` INT DEFAULT NULL, 
  `flexcache_min_reserve_mb` BIGINT DEFAULT NULL, 
  `constituent_role` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are namespace,data,ns_mirror,ols', 
  `is_managed_by_service` BOOL DEFAULT NULL, 
  `storage_class` VARCHAR(255) DEFAULT NULL, 
  `snap_diff_enabled` BOOL DEFAULT NULL, 
  `max_namespace_constituent_size_mb` BIGINT DEFAULT NULL, 
  `max_data_constituent_size_mb` BIGINT DEFAULT NULL, 
  `efficiency_policy_id` INT DEFAULT NULL, 
  `qos_policy_group_id` INT DEFAULT NULL, 
  `language` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are c,ar,cs,da,de,en,en_us,es,fi,fr,he,hr,hu,it,ja,ja_v1,ja_jp.pck,ja_jp.932,ja_jp.pck_v2,ko,no,nl,pl,pt,ro,ru,sk,sl,sv,tr,zh,zh.gbk,zh_tw,zh_tw.big5,c.utf_8,ar.utf_8,cs.utf_8,da.utf_8,de.utf_8,en.utf_8,en_us.utf_8,es.utf_8,fi.utf_8,fr.utf_8,he.utf_8,hr.utf_8,hu.utf_8,it.utf_8,ja.utf_8,ja_v1.utf_8,ja_jp.pck.utf_8,ja_jp.932.utf_8,ja_jp.pck_v2.utf_8,ko.utf_8,no.utf_8,nl.utf_8,pl.utf_8,pt.utf_8,ro.utf_8,ru.utf_8,sk.utf_8,sl.utf_8,sv.utf_8,tr.utf_8,zh.utf_8,zh.gbk.utf_8,zh_tw.utf_8,zh_tw.big5.utf_8', 
  `data_daily_growth_rate_mb` BIGINT DEFAULT NULL, 
  `data_days_until_full` BIGINT DEFAULT NULL, 
  `auto_delete_enabled` BOOL DEFAULT NULL, 
  `auto_delete_commitment` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are try,disrupt,destroy', 
  `auto_delete_delete_order` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are oldest_first,newest_first', 
  `auto_delete_defer_delete` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are scheduled,user_created,prefix,none', 
  `auto_delete_target_free_space` BIGINT DEFAULT NULL, 
  `auto_delete_trigger` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are volume,snap_reserve,space_reserve', 
  `auto_delete_prefix` VARCHAR(255) DEFAULT NULL, 
  `auto_delete_destroy_list` VARCHAR(255) DEFAULT NULL, 
  `snaplock_type` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are non-snaplock,compliance,enterprise', 
  `tiering_policy` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are auto,none,backup,snapshot-only', 
  `is_encrypt` BOOL DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_volume_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_parent_volume` FOREIGN KEY (`parent_volume_id`) REFERENCES `volume` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_snapshot_policy` FOREIGN KEY (`snapshot_policy_id`) REFERENCES `snapshot_policy` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_export_policy` FOREIGN KEY (`export_policy_id`) REFERENCES `export_policy` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_flexcache_origin_volume` FOREIGN KEY (`flexcache_origin_volume_id`) REFERENCES `volume` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_efficiency_policy` FOREIGN KEY (`efficiency_policy_id`) REFERENCES `efficiency_policy` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_qos_policy_group` FOREIGN KEY (`qos_policy_group_id`) REFERENCES `qos_policy_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_volume_vserver` (`vserver_id`), 
  KEY `idx_cm_storage_volume_aggregate` (`aggregate_id`), 
  KEY `idx_cm_storage_volume_parent_volume` (`parent_volume_id`), 
  KEY `idx_cm_storage_volume_snapshot_policy` (`snapshot_policy_id`), 
  KEY `idx_cm_storage_volume_export_policy` (`export_policy_id`), 
  KEY `idx_cm_storage_volume_flexcache_origin_volume` (`flexcache_origin_volume_id`), 
  KEY `idx_cm_storage_volume_efficiency_policy` (`efficiency_policy_id`), 
  KEY `idx_cm_storage_volume_qos_policy_group` (`qos_policy_group_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `volume_annotation` */
DROP TABLE IF EXISTS `volume_annotation`;

CREATE TABLE `volume_annotation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `volume_id` INT NOT NULL, 
  `annotation_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_volume_annotation_volume` FOREIGN KEY (`volume_id`) REFERENCES `volume` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_volume_annotation_annotation` FOREIGN KEY (`annotation_id`) REFERENCES `annotation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_volume_annotation_volume` (`volume_id`), 
  KEY `idx_cm_storage_volume_annotation_annotation` (`annotation_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `vserver` */
DROP TABLE IF EXISTS `vserver`;

CREATE TABLE `vserver` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cluster_id` INT NOT NULL, 
  `root_volume_id` INT DEFAULT NULL, 
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, 
  `type` VARCHAR(255) NOT NULL COMMENT 'possible values are admin,node,cluster,data', 
  `uuid` VARCHAR(255) DEFAULT NULL, 
  `name_service_switch` VARCHAR(255) DEFAULT NULL, 
  `nis_domain` VARCHAR(255) DEFAULT NULL, 
  `language` VARCHAR(32) DEFAULT NULL, 
  `comment` VARCHAR(1024) DEFAULT NULL, 
  `admin_state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are running,stopped,starting,stopping,deleting,initializing', 
  `nfs_allowed` BOOL NOT NULL, 
  `cifs_allowed` BOOL NOT NULL, 
  `fcp_allowed` BOOL NOT NULL, 
  `iscsi_allowed` BOOL NOT NULL, 
  `dns_domain` VARCHAR(255) DEFAULT NULL, 
  `dns_servers` VARCHAR(255) DEFAULT NULL, 
  `snapshot_policy_id` INT DEFAULT NULL, 
  `cifs_is_up` BOOL NOT NULL, 
  `nfs_is_up` BOOL NOT NULL, 
  `fcp_is_up` BOOL NOT NULL, 
  `iscsi_is_up` BOOL NOT NULL, 
  `max_volumes` INT DEFAULT NULL, 
  `restricted_aggregate_count` INT NOT NULL, 
  `cifs_authentication_style` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are domain,workgroup', 
  `cifs_domain` VARCHAR(255) DEFAULT NULL, 
  `nis_enabled` BOOL DEFAULT NULL, 
  `nis_servers` VARCHAR(255) DEFAULT NULL, 
  `is_repository` BOOL DEFAULT NULL, 
  `dns_enabled` BOOL DEFAULT NULL, 
  `qos_policy_group_id` INT DEFAULT NULL, 
  `ipspace_id` INT DEFAULT NULL, 
  `operational_state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are running,stopped', 
  `subtype` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are default,dp-destination,sync-source,sync-destination', 
  `is_smb_encryption_required` BOOL DEFAULT NULL, 
  `is_ddns_enabled` BOOL DEFAULT NULL, 
  `is_ddns_use_secure` BOOL DEFAULT NULL, 
  `ddns_domain_name` VARCHAR(255) DEFAULT NULL, 
  `ddns_ttl` INT DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_vserver_cluster` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_root_volume` FOREIGN KEY (`root_volume_id`) REFERENCES `volume` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_snapshot_policy` FOREIGN KEY (`snapshot_policy_id`) REFERENCES `snapshot_policy` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_qos_policy_group` FOREIGN KEY (`qos_policy_group_id`) REFERENCES `qos_policy_group` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_ipspace` FOREIGN KEY (`ipspace_id`) REFERENCES `ipspace` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_vserver_cluster` (`cluster_id`), 
  KEY `idx_cm_storage_vserver_root_volume` (`root_volume_id`), 
  KEY `idx_cm_storage_vserver_snapshot_policy` (`snapshot_policy_id`), 
  KEY `idx_cm_storage_vserver_qos_policy_group` (`qos_policy_group_id`), 
  KEY `idx_cm_storage_vserver_ipspace` (`ipspace_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `vserver_allowed_aggregate` */
DROP TABLE IF EXISTS `vserver_allowed_aggregate`;

CREATE TABLE `vserver_allowed_aggregate` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `aggregate_id` INT NOT NULL, 
  `vserver_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_vserver_allowed_aggregate_aggregate` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregate` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_allowed_aggregate_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_vserver_allowed_aggregate_aggregate` (`aggregate_id`), 
  KEY `idx_cm_storage_vserver_allowed_aggregate_vserver` (`vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `vserver_annotation` */
DROP TABLE IF EXISTS `vserver_annotation`;

CREATE TABLE `vserver_annotation` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `vserver_id` INT NOT NULL, 
  `annotation_id` INT NOT NULL, 
  CONSTRAINT `fk_cm_storage_vserver_annotation_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_annotation_annotation` FOREIGN KEY (`annotation_id`) REFERENCES `annotation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_vserver_annotation_vserver` (`vserver_id`), 
  KEY `idx_cm_storage_vserver_annotation_annotation` (`annotation_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `vserver_association` */
DROP TABLE IF EXISTS `vserver_association`;

CREATE TABLE `vserver_association` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `source_vserver_id` INT DEFAULT NULL, 
  `destination_vserver_id` INT NOT NULL, 
  `type` VARCHAR(255) NOT NULL COMMENT 'possible values are mirror,vault', 
  `uuid` VARCHAR(255) NOT NULL, 
  UNIQUE KEY `uk_cm_storage_vserver_association_natural_key` (`uuid`),
  CONSTRAINT `fk_cm_storage_vserver_association_source_vserver` FOREIGN KEY (`source_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_association_destination_vserver` FOREIGN KEY (`destination_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_vserver_association_source_vserver` (`source_vserver_id`), 
  KEY `idx_cm_storage_vserver_association_destination_vserver` (`destination_vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* Create table `vserver_peer` */
DROP TABLE IF EXISTS `vserver_peer`;

CREATE TABLE `vserver_peer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `vserver_id` INT NOT NULL, 
  `peer_vserver_id` INT NOT NULL, 
  `peer_state` VARCHAR(255) DEFAULT NULL COMMENT 'possible values are peered,pending,initializing,initiated,rejected,suspended,deleted', 
  `applications` VARCHAR(255) DEFAULT NULL, 
  `peer_vserver_local_name` VARCHAR(255) DEFAULT NULL, 
  CONSTRAINT `fk_cm_storage_vserver_peer_vserver` FOREIGN KEY (`vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  CONSTRAINT `fk_cm_storage_vserver_peer_peer_vserver` FOREIGN KEY (`peer_vserver_id`) REFERENCES `vserver` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION, 
  KEY `idx_cm_storage_vserver_peer_vserver` (`vserver_id`), 
  KEY `idx_cm_storage_vserver_peer_peer_vserver` (`peer_vserver_id`), 
  PRIMARY KEY (`id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
SET SQL_NOTES=@OLD_SQL_NOTES;