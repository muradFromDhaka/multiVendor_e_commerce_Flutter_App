/*
SQLyog Community v13.3.0 (64 bit)
MySQL - 8.0.44 : Database - flutter_project
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`flutter_project` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `flutter_project`;

/*Table structure for table `address` */

DROP TABLE IF EXISTS `address`;

CREATE TABLE `address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `user_user_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKi9kvsde7uw31ihsp4k0pk2q68` (`user_user_name`),
  CONSTRAINT `FKi9kvsde7uw31ihsp4k0pk2q68` FOREIGN KEY (`user_user_name`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `address` */

/*Table structure for table `brands` */

DROP TABLE IF EXISTS `brands`;

CREATE TABLE `brands` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `brands` */

insert  into `brands`(`id`,`description`,`logo_url`,`name`) values 
(1,'popular e-shop','uploadDir/4ac84d94-fc37-4f6c-a034-1681d1c2f817-scaled_1000019063.jpg','adidas'),
(2,'world wide e-shope','uploadDir/e495f19d-a2f1-4c0b-a68e-0576bc8c6be8-scaled_1000019065.jpg','Amazon'),
(3,'dyyuuv yijbfss klouhh','uploadDir/e971c6f8-a260-4a28-91e1-030db07081c8-scaled_1000019064.jpg','Live Shopping');

/*Table structure for table `cart` */

DROP TABLE IF EXISTS `cart`;

CREATE TABLE `cart` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `total_amount` decimal(38,2) DEFAULT NULL,
  `user_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKh343oc2v1f4vs0i3w3r28ou7f` (`user_name`),
  CONSTRAINT `FKh343oc2v1f4vs0i3w3r28ou7f` FOREIGN KEY (`user_name`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `cart` */

insert  into `cart`(`id`,`created_at`,`deleted`,`updated_at`,`total_amount`,`user_name`) values 
(1,'2026-02-26 01:20:21.800145','\0','2026-02-26 01:20:21.800145',0.00,'murad'),
(2,'2026-02-26 01:43:10.975130','\0','2026-02-26 01:43:10.975130',0.00,'Habib'),
(3,'2026-02-26 01:46:47.961218','\0','2026-02-26 01:46:47.961218',0.00,'kamal'),
(4,'2026-02-26 03:10:37.559425','\0','2026-02-26 03:10:37.559425',0.00,'ismam');

/*Table structure for table `cart_item` */

DROP TABLE IF EXISTS `cart_item`;

CREATE TABLE `cart_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `cart_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1uobyhgl1wvgt1jpccia8xxs3` (`cart_id`),
  KEY `FKqkqmvkmbtiaqn2nfqf25ymfs2` (`product_id`),
  CONSTRAINT `FK1uobyhgl1wvgt1jpccia8xxs3` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`),
  CONSTRAINT `FKqkqmvkmbtiaqn2nfqf25ymfs2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `cart_item` */

/*Table structure for table `categories` */

DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `parent_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKsaok720gsu4u2wrgbk10b5n8d` (`parent_id`),
  CONSTRAINT `FKsaok720gsu4u2wrgbk10b5n8d` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `categories` */

insert  into `categories`(`id`,`created_at`,`deleted`,`updated_at`,`image_url`,`name`,`parent_id`) values 
(1,'2026-02-26 01:34:25.771103','\0','2026-02-26 01:34:25.771103','uploadDir/c73bec49-0713-442e-a6d3-9c1d06c28aa2-scaled_1000019079.jpg','Cloth',NULL),
(2,'2026-02-26 01:34:53.973714','\0','2026-02-26 01:35:04.776630','uploadDir/0c40b3bd-2103-4643-9937-d3ba997c8024-scaled_1000019080.jpg','Men\'s Clothing',1),
(3,'2026-02-26 01:35:34.979645','\0','2026-02-26 01:35:34.979645','uploadDir/446d172e-7207-41a8-9f36-acbdbf3e0240-scaled_1000019080.jpg','women\'s Clothing',1),
(4,'2026-02-26 01:36:10.807775','\0','2026-02-26 01:36:10.807775','uploadDir/6c0323b9-9b8a-47e4-a352-205c527d8ba7-scaled_1000019077.jpg','Kid\'s Clothing',1),
(5,'2026-02-26 01:36:46.003900','\0','2026-02-26 01:36:46.003900','uploadDir/a93bac62-56d8-4128-b715-f6ae288a8393-scaled_1000019076.jpg','Footwear',1),
(6,'2026-02-26 01:40:15.083535','\0','2026-02-26 01:40:15.083535','uploadDir/1f0c96bf-af65-4001-9213-8f92f07ddb5f-scaled_1000019078.jpg','Juwelry & Watches',NULL);

/*Table structure for table `deals` */

DROP TABLE IF EXISTS `deals`;

CREATE TABLE `deals` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `discount_percent` int NOT NULL,
  `end_time` datetime(6) NOT NULL,
  `start_time` datetime(6) NOT NULL,
  `title` varchar(150) NOT NULL,
  `product_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKdiyxm7qwacnjy62mr34jn35p6` (`product_id`),
  CONSTRAINT `FKdiyxm7qwacnjy62mr34jn35p6` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `deals` */

/*Table structure for table `inventory` */

DROP TABLE IF EXISTS `inventory`;

CREATE TABLE `inventory` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `available_quantity` int DEFAULT NULL,
  `reserved_quantity` int DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKce3rbi3bfstbvvyne34c1dvyv` (`product_id`),
  CONSTRAINT `FKq2yge7ebtfuvwufr6lwfwqy9l` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `inventory` */

/*Table structure for table `order_items` */

DROP TABLE IF EXISTS `order_items`;

CREATE TABLE `order_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `vendor_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKbioxgbv59vetrxe0ejfubep1w` (`order_id`),
  KEY `FKocimc7dtr037rh4ls4l95nlfi` (`product_id`),
  KEY `FKh2b04eyamwe2jqedwv3lbrx7f` (`vendor_id`),
  CONSTRAINT `FKbioxgbv59vetrxe0ejfubep1w` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `FKh2b04eyamwe2jqedwv3lbrx7f` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`),
  CONSTRAINT `FKocimc7dtr037rh4ls4l95nlfi` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `order_items` */

/*Table structure for table `orders` */

DROP TABLE IF EXISTS `orders`;

CREATE TABLE `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `order_status` enum('CANCELLED','DELIVERED','PAID','PENDING','SHIPPED') NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKh7qbv78dn5rihkihp4h6rt2lr` (`user_name`),
  CONSTRAINT `FKh7qbv78dn5rihkihp4h6rt2lr` FOREIGN KEY (`user_name`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `orders` */

/*Table structure for table `payment` */

DROP TABLE IF EXISTS `payment`;

CREATE TABLE `payment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `status` enum('FAILED','INITIATED','SUCCESS') DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `order_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKmf7n8wo2rwrxsd6f3t9ub2mep` (`order_id`),
  CONSTRAINT `FKlouu98csyullos9k25tbpk4va` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `payment` */

/*Table structure for table `product_images` */

DROP TABLE IF EXISTS `product_images`;

CREATE TABLE `product_images` (
  `product_id` bigint NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  KEY `FKqnq71xsohugpqwf3c9gxmsuy` (`product_id`),
  CONSTRAINT `FKqnq71xsohugpqwf3c9gxmsuy` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `product_images` */

insert  into `product_images`(`product_id`,`image_url`) values 
(1,'uploadDir/67472814-a9cc-40dc-9eab-227192189d18-scaled_1000019103.jpg'),
(1,'uploadDir/a9f339c9-fbaf-4ff5-b1be-9d6beab2634e-scaled_1000019102.jpg'),
(2,'uploadDir/d908d250-17aa-4d07-85a7-5d7862788087-scaled_1000019102.jpg'),
(2,'uploadDir/a4b450bb-ee65-4763-abde-1ceb64eb462d-scaled_1000019098.jpg'),
(3,'uploadDir/67fd49fe-62d6-47c1-9f8e-13c3dbf8f333-scaled_1000019098.jpg'),
(3,'uploadDir/8b170a9f-aaa0-4c04-a476-d2feb54a55ad-scaled_1000019103.jpg'),
(4,'uploadDir/2c9ca753-a850-4ad3-b59f-9d13336362f6-scaled_1000019098.jpg'),
(4,'uploadDir/0d034883-412d-42ad-b568-f6d4fccaaa02-scaled_1000019102.jpg'),
(4,'uploadDir/cbb11b09-0f0f-448b-8373-35b801088d03-scaled_1000019101.jpg'),
(5,'uploadDir/d8623ad8-aa98-4cfb-b2c8-3f96174ba40b-scaled_1000019096.jpg'),
(5,'uploadDir/e1f044dd-6ba5-4956-b97d-6750f361f8cf-scaled_1000019098.jpg'),
(5,'uploadDir/f3b2788d-608d-4137-8f8d-6e6fa8e92828-scaled_1000019102.jpg'),
(5,'uploadDir/85a0e958-a117-43bf-993a-fe425905ad16-scaled_1000019103.jpg'),
(6,'uploadDir/b56ec8c5-d36a-45af-a96e-e499c11eec36-scaled_1000019120.jpg'),
(6,'uploadDir/f364e12c-0617-40a5-944a-4a9db6af5b74-scaled_1000019119.jpg'),
(6,'uploadDir/15cf54b2-1420-4361-9833-184211d7510e-scaled_1000019122.jpg'),
(7,'uploadDir/102f3363-e28f-43c7-ab5a-15ef5893aa9e-scaled_1000019122.jpg'),
(7,'uploadDir/31e12189-da34-43ab-bc57-23b8d36d86c2-scaled_1000019119.jpg'),
(7,'uploadDir/80c575e9-a37a-4fda-af5b-5a0da3a7fc71-scaled_1000019118.jpg'),
(8,'uploadDir/af39a2c7-0893-44b6-8b11-747701a8d396-scaled_1000019116.jpg'),
(8,'uploadDir/460b4ea2-d57c-4dae-9104-44089e502c93-scaled_1000019118.jpg'),
(8,'uploadDir/92ec0b39-d447-4001-82c3-42fc11282272-scaled_1000019119.jpg'),
(9,'uploadDir/cd40bfcc-d318-4585-895e-042fb48c5740-scaled_1000019123.jpg'),
(9,'uploadDir/c85ecfcd-f7a5-4d6f-a606-f2de058d2008-scaled_1000019119.jpg'),
(9,'uploadDir/732f2436-5466-45a6-a500-960fb9f67df6-scaled_1000019120.jpg'),
(9,'uploadDir/671287a2-d596-406e-adcd-3ee97fea3479-scaled_1000019118.jpg'),
(10,'uploadDir/565d99c8-f397-4efb-90bb-945e1d880377-scaled_1000019119.jpg'),
(10,'uploadDir/3550c7ca-d583-4061-b690-01b9261a5e47-scaled_1000019121.jpg'),
(10,'uploadDir/b0239e68-f5fc-413d-b749-a1909459fcbf-scaled_1000019118.jpg'),
(10,'uploadDir/5a64f1b4-3bca-4efd-ba6d-c1c072784529-scaled_1000019122.jpg'),
(10,'uploadDir/5e0fbb2e-b896-465a-b62a-05706828462d-scaled_1000019123.jpg'),
(11,'uploadDir/e477c50e-002d-40d5-9744-0539efa927f8-scaled_1000019144.jpg'),
(11,'uploadDir/16f7ac79-8e8a-49d3-bda6-143a11f813e0-scaled_1000019143.jpg'),
(12,'uploadDir/82f13bd6-41b5-444f-9c21-3b3213528bfa-scaled_1000019147.jpg'),
(12,'uploadDir/fa0c09b0-deb4-49e7-86c5-41366af682bd-scaled_1000019149.jpg'),
(12,'uploadDir/93a910c7-7c94-466c-b4d9-506739e95b39-scaled_1000019146.jpg'),
(12,'uploadDir/8cb25d5f-ac0f-4254-a28e-0bd3dc116f3c-scaled_1000019148.jpg'),
(13,'uploadDir/7af7d673-254c-408b-ad32-4ad232c79bd1-scaled_1000019144.jpg'),
(13,'uploadDir/251ba3d3-8c64-4c36-8b83-6013d0ecc8b1-scaled_1000019143.jpg'),
(13,'uploadDir/578ae4ba-d976-4446-999c-6d254877404d-scaled_1000019142.jpg'),
(14,'uploadDir/a7c42a75-7e1a-4231-91d3-b5c09a08d7ee-scaled_1000019150.jpg'),
(14,'uploadDir/1afa394b-c32e-473f-93d2-5c85d21abf8b-scaled_1000019151.jpg'),
(14,'uploadDir/260ce60f-6b57-450a-bc8c-9564af9e2ecf-scaled_1000019148.jpg'),
(15,'uploadDir/4f4782b0-b441-433e-966e-19d9243d6cf2-scaled_1000019145.jpg'),
(15,'uploadDir/b29fc527-85b3-4c9c-9b54-625848429b52-scaled_1000019148.jpg'),
(15,'uploadDir/278e3b62-3bb4-43d9-aef4-1c7031a0d834-scaled_1000019147.jpg'),
(15,'uploadDir/ae868d6e-2d35-4d88-8336-dac1d5feb8ac-scaled_1000019146.jpg'),
(15,'uploadDir/2dc919cd-e10b-49f7-a3c4-b70a6a26f31d-scaled_1000019149.jpg'),
(16,'uploadDir/ec5fcded-ecb7-49e8-8409-a7a2f48ccb98-scaled_1000019142.jpg'),
(16,'uploadDir/619cd653-fd31-4ac5-98fe-4182649a1fa7-scaled_1000019151.jpg'),
(16,'uploadDir/45489d24-730d-4605-916c-6e1548c7c9e5-scaled_1000019150.jpg'),
(16,'uploadDir/5e385c61-661c-4311-900e-193406140d29-scaled_1000019147.jpg'),
(16,'uploadDir/72c9eb09-6a2a-47dc-8dd5-a2b63e782e7e-scaled_1000019148.jpg'),
(16,'uploadDir/85a369b5-ea43-4356-b249-00dfb339f34c-scaled_1000019144.jpg'),
(16,'uploadDir/852e7ef7-95cd-4df0-b134-38c9de3706c8-scaled_1000019143.jpg'),
(17,'uploadDir/f9c005be-9960-4123-a35c-8da9414a1601-scaled_1000019191.jpg'),
(17,'uploadDir/28876942-f086-4b7e-8452-0d8c17fcad1e-scaled_1000019189.jpg'),
(18,'uploadDir/23d5b266-e4a1-40a1-9187-4fa004cb4763-scaled_1000019184.jpg'),
(18,'uploadDir/13243476-9b71-446f-8b9e-a208998aa347-scaled_1000019183.jpg'),
(19,'uploadDir/29959bdb-50ca-4e8a-a835-1a8be24f7c5b-scaled_1000019181.jpg'),
(19,'uploadDir/a2502c27-0f83-4bae-bf3a-55b4767f2fad-scaled_1000019180.jpg'),
(19,'uploadDir/83ce64c4-3dd6-4341-ac11-f2a8772322bf-scaled_1000019182.jpg'),
(20,'uploadDir/182f7cd5-3475-4b55-a43a-5616a6ccb5de-scaled_1000019185.jpg'),
(20,'uploadDir/5b4154dd-5772-468d-bdf8-a2f66591f027-scaled_1000019184.jpg'),
(20,'uploadDir/08445fd0-0377-4b93-a4bd-90ce02826443-scaled_1000019187.jpg'),
(20,'uploadDir/924ed984-0f85-438d-bdfc-a5bcb418616f-scaled_1000019183.jpg'),
(21,'uploadDir/971aa771-edbf-45f9-9e6c-47e7456be07e-scaled_1000019181.jpg'),
(21,'uploadDir/c4b9b579-42da-4028-8156-8916088a71b6-scaled_1000019183.jpg'),
(21,'uploadDir/6b631916-e2c3-470b-b320-e61174c9a030-scaled_1000019187.jpg'),
(22,'uploadDir/9bd7dfb3-dc25-45b3-9daf-0d7233422482-scaled_1000019187.jpg'),
(22,'uploadDir/2f2e01c9-3169-4d75-90cd-380307e5da28-scaled_1000019190.jpg'),
(22,'uploadDir/fd99dbf3-2edf-4d8d-b1c8-4cddb80507ef-scaled_1000019191.jpg'),
(22,'uploadDir/94952868-9584-4809-bb03-bafa66302ec0-scaled_1000019189.jpg'),
(22,'uploadDir/86de8503-27f4-434e-954d-6437a4f1504e-scaled_1000019186.jpg'),
(23,'uploadDir/ce74b67f-ebd9-403b-a0bf-272c85f061ac-scaled_1000019211.jpg'),
(23,'uploadDir/14241cd3-d462-432c-a833-b47a0c3dc3bc-scaled_1000019210.jpg'),
(23,'uploadDir/a9758667-3c97-4ccd-8086-5526c9d1fe15-scaled_1000019209.jpg'),
(24,'uploadDir/7713946b-07b4-4e82-b289-e0e87285fd8a-scaled_1000019208.jpg'),
(24,'uploadDir/339462c4-f05f-481c-a268-dc83cb5c814b-scaled_1000019204.jpg'),
(24,'uploadDir/b5e34314-1f4b-42de-b52c-7c78f7f9f228-scaled_1000019206.jpg'),
(25,'uploadDir/802b46ab-9b7e-4423-9b2d-6b222c265a70-scaled_1000019207.jpg'),
(25,'uploadDir/763d6f18-acda-4711-88c2-12e859a5ac14-scaled_1000019206.jpg'),
(25,'uploadDir/ba523bd3-9371-4001-95a4-4ac0cfeb5aaa-scaled_1000019191.jpg'),
(25,'uploadDir/15e02fcd-453e-4f2b-8f4b-9f0e488f36c0-scaled_1000019209.jpg'),
(25,'uploadDir/6b84b389-64b4-4253-add5-0c39b05a5eeb-scaled_1000019210.jpg'),
(26,'uploadDir/dfc6a1e2-c91d-4f90-912f-76e2f4d5b6ae-scaled_1000019208.jpg'),
(26,'uploadDir/8151d5ee-9a5f-404b-bd9a-f11f310db379-scaled_1000019207.jpg'),
(26,'uploadDir/77b14152-20ed-43a3-8bfa-1033e0fa80c1-scaled_1000019210.jpg'),
(26,'uploadDir/e02962f2-ac43-4104-82c8-3c2ae3555375-scaled_1000019211.jpg'),
(26,'uploadDir/4f819942-348c-455d-8640-65635e8d9c3d-scaled_1000019209.jpg'),
(26,'uploadDir/8a2f141b-c090-4f34-bcef-c47669f0eba8-scaled_1000019206.jpg');

/*Table structure for table `product_variants` */

DROP TABLE IF EXISTS `product_variants`;

CREATE TABLE `product_variants` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `price_adjustment` decimal(38,2) DEFAULT NULL,
  `stock` int DEFAULT NULL,
  `variant_name` varchar(255) DEFAULT NULL,
  `variant_value` varchar(255) DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKosqitn4s405cynmhb87lkvuau` (`product_id`),
  CONSTRAINT `FKosqitn4s405cynmhb87lkvuau` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `product_variants` */

/*Table structure for table `products` */

DROP TABLE IF EXISTS `products`;

CREATE TABLE `products` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `average_rating` double DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `discount_price` decimal(38,2) DEFAULT NULL,
  `product_name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `release_date` date DEFAULT NULL,
  `sku` varchar(255) NOT NULL,
  `sold_count` int NOT NULL,
  `status` enum('ACTIVE','DISCONTINUED','DRAFT','OUT_OF_STOCK') DEFAULT NULL,
  `stock_quantity` int DEFAULT NULL,
  `total_reviews` int DEFAULT NULL,
  `brand_id` bigint DEFAULT NULL,
  `category_id` bigint DEFAULT NULL,
  `vendor_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKfhmd06dsmj6k0n90swsh8ie9g` (`sku`),
  KEY `FKa3a4mpsfdf4d2y6r8ra3sc8mv` (`brand_id`),
  KEY `FKog2rp4qthbtt2lfyhfo32lsw9` (`category_id`),
  KEY `FKs6kdu75k7ub4s95ydsr52p59s` (`vendor_id`),
  CONSTRAINT `FKa3a4mpsfdf4d2y6r8ra3sc8mv` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`),
  CONSTRAINT `FKog2rp4qthbtt2lfyhfo32lsw9` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `FKs6kdu75k7ub4s95ydsr52p59s` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `products` */

insert  into `products`(`id`,`created_at`,`deleted`,`updated_at`,`average_rating`,`description`,`discount_price`,`product_name`,`price`,`release_date`,`sku`,`sold_count`,`status`,`stock_quantity`,`total_reviews`,`brand_id`,`category_id`,`vendor_id`) values 
(1,'2026-02-26 02:04:07.953109','\0','2026-02-26 02:04:07.953109',NULL,'jshzhhzhz shshshh sjsjhshs',NULL,'Cotton T-Shart',2000.00,NULL,'wr',0,NULL,20,NULL,3,2,1),
(2,'2026-02-26 02:05:31.245132','\0','2026-02-26 02:05:31.245132',NULL,'ddsdyhj jkkhgfdc hgdfuugh',NULL,'Business Shart',1750.00,NULL,'kj',0,NULL,25,NULL,3,2,1),
(3,'2026-02-26 02:06:38.602528','\0','2026-02-26 02:06:38.602528',NULL,'guihggg vgutrt hgffh',NULL,'Casual Shart',1500.00,NULL,'ghg',0,NULL,17,NULL,3,2,1),
(4,'2026-02-26 02:07:52.923563','\0','2026-02-26 02:07:52.923563',NULL,'khfvhydf gufdgj hjvgtg',NULL,'Polo T-Shart',1750.00,NULL,'afc',0,NULL,24,NULL,3,2,1),
(5,'2026-02-26 02:09:49.946286','\0','2026-02-26 02:09:49.946286',NULL,'hutfgjbh yhggj ujkkj',NULL,'Smart T-shirt',2152.00,NULL,'hgy',0,NULL,14,NULL,3,2,1),
(6,'2026-02-26 02:17:22.794823','\0','2026-02-26 02:17:22.794823',NULL,'ghgdfgi frtghxv hyfds hhhb',NULL,'evening gown',4000.00,NULL,'kjh',0,NULL,24,NULL,3,3,2),
(7,'2026-02-26 02:18:22.564265','\0','2026-02-26 02:18:22.564265',NULL,'kuyghnn gdshjn hybjjd fdhb',NULL,'Long Gown',1527.00,NULL,'htgg',0,NULL,25,NULL,2,3,2),
(8,'2026-02-26 02:19:26.185531','\0','2026-02-26 02:19:26.185531',NULL,'gjtgjjn uuttghh jjnbfff',NULL,'Crop Top gown',2600.00,NULL,'kjg',0,NULL,25,NULL,2,3,2),
(9,'2026-02-26 02:20:29.520068','\0','2026-02-26 02:20:29.520068',NULL,'ettrguu jitfgjwh jkmhdfh uyddgbh',NULL,'Denim Jacket',2400.00,NULL,'hkkhh',0,NULL,24,NULL,2,3,2),
(10,'2026-02-26 02:22:16.046778','\0','2026-02-26 02:22:16.046778',NULL,'httfjjgbb',NULL,'Coton Kurti',452.00,NULL,'ghu',0,NULL,4,NULL,1,3,2),
(11,'2026-02-26 02:30:44.029427','\0','2026-02-26 02:30:44.029427',NULL,'fdfhhv uijhh yyfg',NULL,'Mini Coton T-shirt',454.00,NULL,'jg',0,NULL,52,NULL,2,4,2),
(12,'2026-02-26 02:31:51.495433','\0','2026-02-26 02:31:51.495433',NULL,'ggghjj kkgfg gsdgh hhvv',NULL,'Little Explorer Hoodie',1452.00,NULL,'aws',0,NULL,12,NULL,2,4,1),
(13,'2026-02-26 02:33:11.374546','\0','2026-02-26 02:33:11.374546',NULL,'ashduusvsuehdh ejdhxhdh',NULL,'Baby Jacket',1845.00,NULL,'faf',0,NULL,24,NULL,2,4,2),
(14,'2026-02-26 02:34:05.373869','\0','2026-02-26 02:34:05.373869',NULL,'hsuxhxux',NULL,'Cute Jama set',1245.00,NULL,'aghs',0,NULL,12,NULL,2,4,1),
(15,'2026-02-26 02:34:53.779741','\0','2026-02-26 02:34:53.779741',NULL,'hzhxhxhw djxhxhwj kshxhdjw euxhhx',NULL,'Baby party dress',56834.00,NULL,'hssh',0,NULL,12,NULL,1,4,1),
(16,'2026-02-26 02:37:00.500360','\0','2026-02-26 02:37:00.500360',NULL,'guijhg hutgh uuii',NULL,'baby dress',14.00,NULL,'wra',0,NULL,125,NULL,2,2,1),
(17,'2026-02-26 02:49:53.989329','\0','2026-02-26 02:49:53.989329',NULL,'shxhxhdhhs sgzghsus shhshsys',NULL,'Necklace',15454.00,NULL,'sffs',0,NULL,12,NULL,1,6,2),
(18,'2026-02-26 02:50:44.893892','\0','2026-02-26 02:50:44.893892',NULL,'xgshshhxvsushs. shdhgsus shdgdg',NULL,'Bracelet',125454.00,NULL,'taw',0,NULL,45,NULL,2,6,2),
(19,'2026-02-26 02:51:36.302498','\0','2026-02-26 02:51:36.302498',NULL,'xgxhhx shhxhzhx sususgshs jsvsvs',NULL,'Stone Ring',2405.00,NULL,'gs',0,NULL,24,NULL,3,6,2),
(20,'2026-02-26 02:52:29.022512','\0','2026-02-26 02:52:29.022512',NULL,'sghxhx',NULL,'Gold chain',454848.00,NULL,'sfg',0,NULL,45,NULL,3,6,2),
(21,'2026-02-26 02:53:51.100576','\0','2026-02-26 02:53:51.100576',NULL,'xgxhdh dhxhhx dhdhd',NULL,'Stainless steel chain',12454.00,NULL,'xg',0,NULL,21,NULL,2,6,2),
(22,'2026-02-26 02:55:28.419201','\0','2026-02-26 02:55:28.420202',NULL,'zghzhxhz sjxhhdhd sjdhxhd',NULL,'Gold Bracelet',2457.00,NULL,'taf',0,NULL,45,NULL,1,6,2),
(23,'2026-02-26 03:01:22.134458','\0','2026-02-26 03:01:22.134458',NULL,'xgdhdu sushdhvdudu',NULL,'Steel chain Necklace',1254.00,NULL,'gsgsys',0,NULL,875,NULL,2,6,1),
(24,'2026-02-26 03:05:25.136049','\0','2026-02-26 03:05:25.136049',NULL,'zh hggehxbrchfjrcjr xhexh',NULL,'Black Band Ring',4528.00,NULL,'fguh',0,NULL,8,NULL,1,6,1),
(25,'2026-02-26 03:07:04.443168','\0','2026-02-26 03:07:04.443168',NULL,'gughh',NULL,'classic knight band',9655.00,NULL,'rfhuc',0,NULL,25,NULL,1,6,1),
(26,'2026-02-26 03:20:07.322245','\0','2026-02-26 03:20:54.870012',NULL,'ghddfh hfdxcv hjhvff',NULL,'Shadow Black Ring',145222.00,NULL,'ggff',0,NULL,25,NULL,1,6,3);

/*Table structure for table `reviews` */

DROP TABLE IF EXISTS `reviews`;

CREATE TABLE `reviews` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKpl51cejpw4gy5swfar8br9ngi` (`product_id`),
  KEY `FKsdlcf7wf8l1k0m00gik0m6b1m` (`user_id`),
  CONSTRAINT `FKpl51cejpw4gy5swfar8br9ngi` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `FKsdlcf7wf8l1k0m00gik0m6b1m` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `reviews` */

/*Table structure for table `role` */

DROP TABLE IF EXISTS `role`;

CREATE TABLE `role` (
  `role_name` varchar(255) NOT NULL,
  `date_created` datetime(6) NOT NULL,
  `last_updated` datetime(6) NOT NULL,
  `role_description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `role` */

insert  into `role`(`role_name`,`date_created`,`last_updated`,`role_description`) values 
('ROLE_ADMIN','2026-02-25 19:11:21.763794','2026-02-25 19:11:21.763794','Admin role'),
('ROLE_MODERATOR','2026-02-25 19:11:21.839751','2026-02-25 19:11:21.839751','Default role for newly ROLE_MODERATOR record'),
('ROLE_USER','2026-02-25 19:11:21.826758','2026-02-25 19:11:21.826758','Default role for newly created record'),
('ROLE_VENDOR','2026-02-25 19:11:21.831756','2026-02-25 19:11:21.831756','Default role for newly created record');

/*Table structure for table `user` */

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `user_name` varchar(255) NOT NULL,
  `account_non_expired` bit(1) DEFAULT NULL,
  `account_non_locked` bit(1) DEFAULT NULL,
  `credentials_non_expired` bit(1) DEFAULT NULL,
  `date_created` datetime(6) NOT NULL,
  `email` varchar(255) NOT NULL,
  `enabled` bit(1) DEFAULT NULL,
  `last_updated` datetime(6) NOT NULL,
  `password` varchar(255) NOT NULL,
  `user_first_name` varchar(255) DEFAULT NULL,
  `user_last_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_name`),
  UNIQUE KEY `UKob8kqyqqgmefl0aco34akdtpe` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `user` */

insert  into `user`(`user_name`,`account_non_expired`,`account_non_locked`,`credentials_non_expired`,`date_created`,`email`,`enabled`,`last_updated`,`password`,`user_first_name`,`user_last_name`) values 
('abc','','','','2026-02-25 21:08:45.181540','abc@gmail.com','','2026-02-25 21:08:45.181540','$2a$10$6AiR.w2w6cZUfXX3aJH9QOi7IpbNCLIRbqvtk47dONQSisSQHEtZq','abc','abc'),
('Habib','','','','2026-02-25 19:42:01.465816','habib@gmail.com','','2026-02-25 20:47:41.041459','$2a$10$NkvpUdFayb08DLMI34FGUeeUITeIewU2cjfqttFJC3N63J3RFU06.','Habib','Habib'),
('ismam','','','','2026-02-25 21:08:08.846699','ismam@gmail.com','','2026-02-25 21:18:47.343988','$2a$10$J47jGKlpA0GyQltTTvB/zen4pMvETH2hqQxiV34R/bGDefi3wka/S','ismam','ismam'),
('kamal','','','','2026-02-25 19:42:43.915947','kamal@gmail.com','','2026-02-25 20:47:52.644140','$2a$10$XjdsSlqFzvmZTUA7wiWtl./LSFiEUHsiCMR9me8HElCOpDaf/sCo2','kamal','kamal'),
('murad','','','','2026-02-25 19:11:22.049631','murad@gmail.com','','2026-02-25 19:11:22.069619','$2a$10$DIEoXUFDHRaRaXmwZCbKguBghTbJDMD.oSiaVtwQ2H9IRrN99yYqu','murad','murad'),
('xyz','','','','2026-02-25 21:09:20.494606','xyz@gmail.com','','2026-02-25 21:09:20.494606','$2a$10$xiLHilBA5Jh4cCzLBLDV8.Fgz38h3c3ZxhIm/MAW9linlFuV5.n9.','xyz','xyz');

/*Table structure for table `user_product_views` */

DROP TABLE IF EXISTS `user_product_views`;

CREATE TABLE `user_product_views` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `viewed_at` datetime(6) DEFAULT NULL,
  `product_id` bigint NOT NULL,
  `user_id` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKdbaaq3a1ag0yxt7is5b3ey9wv` (`product_id`),
  KEY `FKkhnrtn9lavum7dpvbc5wqfvse` (`user_id`),
  CONSTRAINT `FKdbaaq3a1ag0yxt7is5b3ey9wv` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `FKkhnrtn9lavum7dpvbc5wqfvse` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `user_product_views` */

/*Table structure for table `userrole` */

DROP TABLE IF EXISTS `userrole`;

CREATE TABLE `userrole` (
  `user_name` varchar(255) NOT NULL,
  `role_name` varchar(255) NOT NULL,
  PRIMARY KEY (`user_name`,`role_name`),
  KEY `FK7x82xdby6jkfkj7n1rt8es9er` (`role_name`),
  CONSTRAINT `FK7x82xdby6jkfkj7n1rt8es9er` FOREIGN KEY (`role_name`) REFERENCES `role` (`role_name`),
  CONSTRAINT `FKk3ctmjfke6dpm6m9iirjb3kh0` FOREIGN KEY (`user_name`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `userrole` */

insert  into `userrole`(`user_name`,`role_name`) values 
('murad','ROLE_ADMIN'),
('murad','ROLE_MODERATOR'),
('abc','ROLE_USER'),
('xyz','ROLE_USER'),
('Habib','ROLE_VENDOR'),
('ismam','ROLE_VENDOR'),
('kamal','ROLE_VENDOR');

/*Table structure for table `vendor_orders` */

DROP TABLE IF EXISTS `vendor_orders`;

CREATE TABLE `vendor_orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `status` enum('CANCELLED','CONFIRMED','DELIVERED','PENDING','SHIPPED') DEFAULT NULL,
  `subtotal` decimal(38,2) DEFAULT NULL,
  `order_id` bigint DEFAULT NULL,
  `vendor_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKc0ijaglxwy47i5qvryd6fglu0` (`order_id`),
  KEY `FKgnnw47lqw9epw5soxdg69nbbh` (`vendor_id`),
  CONSTRAINT `FKc0ijaglxwy47i5qvryd6fglu0` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `FKgnnw47lqw9epw5soxdg69nbbh` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `vendor_orders` */

/*Table structure for table `vendor_payouts` */

DROP TABLE IF EXISTS `vendor_payouts`;

CREATE TABLE `vendor_payouts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `amount` decimal(38,2) NOT NULL,
  `method` varchar(255) NOT NULL,
  `payout_date` datetime(6) DEFAULT NULL,
  `reference` varchar(255) NOT NULL,
  `status` enum('PAID','PENDING') NOT NULL,
  `vendor_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKr3qmvyi2ucgm0gf56a6xnn9cm` (`reference`),
  KEY `FKmugulu8p827i90o7w5vevew2j` (`vendor_id`),
  CONSTRAINT `FKmugulu8p827i90o7w5vevew2j` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `vendor_payouts` */

/*Table structure for table `vendors` */

DROP TABLE IF EXISTS `vendors`;

CREATE TABLE `vendors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `banner_url` varchar(255) DEFAULT NULL,
  `business_email` varchar(255) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `shop_name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `status` enum('ACTIVE','PENDING','SUSPENDED') DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK2cmurjys8e1l80e0prvvdq19g` (`shop_name`),
  UNIQUE KEY `UK326w4yy3sqwkmpnd4gaqqfb13` (`slug`),
  UNIQUE KEY `UK33novltf5e2ys3noppqkegol` (`username`),
  CONSTRAINT `FKh99u3iwyyxivpoi57o9tdpu8j` FOREIGN KEY (`username`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `vendors` */

insert  into `vendors`(`id`,`created_at`,`deleted`,`updated_at`,`address`,`banner_url`,`business_email`,`description`,`logo_url`,`phone`,`rating`,`shop_name`,`slug`,`status`,`username`) values 
(1,'2026-02-26 01:45:57.463715','\0','2026-02-26 01:45:57.463715','Cox’s Bazar','https://www.shutterstock.com/image-photo/traveler-woman-arms-raised-triumph-260nw-2457990309.jpg','habibShope@gmail.com','hddjfjg fjufurd','https://www.shutterstock.com/image-photo/traveler-woman-arms-raised-triumph-260nw-2457990309.jpg','0187524555',0,'Habib Online Shope','habib-online-shope','PENDING','Habib'),
(2,'2026-02-26 01:51:28.266443','\0','2026-02-26 01:51:28.266443','Dhaka','https://i0.wp.com/picjumbo.com/wp-content/uploads/detailed-shot-of-ripples-at-sunset-free-image.jpeg?w=600&quality=80','kamalShope@gmail.com','lkhhhjj. sewrtyy','https://i0.wp.com/picjumbo.com/wp-content/uploads/detailed-shot-of-ripples-at-sunset-free-image.jpeg?w=600&quality=80','05588548824',0,'Kamal degital Shope','kamal-degital-shope','PENDING','kamal'),
(3,'2026-02-26 03:17:16.161954','\0','2026-02-26 03:17:16.161954','rfddad','https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2bwqSVBeZ5FW_IKdIcDjZ-CaoBhPZ5eAFxUYC7KY3qw6aSiLAcpLiA2vU&s=10','ismam@gmail.com','gtsfgh','https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2bwqSVBeZ5FW_IKdIcDjZ-CaoBhPZ5eAFxUYC7KY3qw6aSiLAcpLiA2vU&s=10','55885',0,'ismam Online shop','ismam-online-shop','PENDING','ismam');

/*Table structure for table `wishlist` */

DROP TABLE IF EXISTS `wishlist`;

CREATE TABLE `wishlist` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `deleted` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKd4r80jm8s41fgoa0xv9yy5lo8` (`user_id`),
  CONSTRAINT `FKd4r80jm8s41fgoa0xv9yy5lo8` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `wishlist` */

/*Table structure for table `wishlist_products` */

DROP TABLE IF EXISTS `wishlist_products`;

CREATE TABLE `wishlist_products` (
  `wishlist_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  PRIMARY KEY (`wishlist_id`,`product_id`),
  KEY `FKpj5y3q6hyu53f8q4pd6n7rndc` (`product_id`),
  CONSTRAINT `FKhlq0ylq5sxd70s0pembuumc1d` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlist` (`id`),
  CONSTRAINT `FKpj5y3q6hyu53f8q4pd6n7rndc` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `wishlist_products` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
