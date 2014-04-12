-- MySQL dump 10.13  Distrib 5.5.9, for Win32 (x86)
--
-- Host: localhost    Database: ppyn_development
-- ------------------------------------------------------
-- Server version	5.5.9

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `states`
--

DROP TABLE IF EXISTS `states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `states` (
  `id` double NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sortkey` double DEFAULT NULL,
  `hide` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `states`
--

LOCK TABLES `states` WRITE;
/*!40000 ALTER TABLE `states` DISABLE KEYS */;
INSERT INTO `states` VALUES (1,'AK','Alaska',3,'',''),(2,'AL','Alabama',2,'',''),(3,'AR','Arkansas',5,'',''),(4,'AZ','Arizona',4,'',''),(5,'CA','California',1,'',''),(6,'CO','Colorado',6,'',''),(7,'CT','Connecticut',7,'',''),(8,'DC','District of Columbia',9,'',''),(9,'DE','Delaware',8,'',''),(10,'FL','Florida',10,'',''),(11,'GA','Georgia',11,'',''),(12,'GU','Guam',12,'',''),(13,'HI','Hawaii',13,'',''),(14,'IA','Iowa',17,'',''),(15,'ID','Idaho',14,'',''),(16,'IL','Illinois',15,'',''),(17,'IN','Indiana',16,'',''),(18,'KS','Kansas',18,'',''),(19,'KY','Kentucky',19,'',''),(20,'LA','Louisana',20,'',''),(21,'MA','Massachusetts',23,'',''),(22,'MD','Maryland',22,'',''),(23,'ME','Maine',21,'',''),(24,'MI','Michigan',24,'',''),(25,'MN','Minnesota',25,'',''),(26,'MO','Missouri',27,'',''),(27,'MS','Mississippi',26,'',''),(28,'MT','Montana',28,'',''),(29,'NC','North Carolina',35,'',''),(30,'ND','North Dakota',36,'',''),(31,'NE','Nebraska',29,'',''),(32,'NH','New Hampshire',31,'',''),(33,'NJ','New Jersey',32,'',''),(34,'NM','New Mexico',33,'',''),(35,'NV','Nevada',30,'',''),(36,'NY','New York',34,'',''),(37,'OH','Ohio',37,'',''),(38,'OK','Oklahoma',38,'',''),(39,'OR','Oregon',39,'',''),(40,'PA','Pennsylvania',40,'',''),(41,'PR','Puerto Rico',41,'',''),(42,'RI','Rhode Island',42,'',''),(43,'SC','South Carolina',43,'',''),(44,'SD','South Dakota',44,'',''),(45,'TN','Tennessee',45,'',''),(46,'TX','Texas',46,'',''),(47,'UT','Utah',47,'',''),(48,'VA','Virginia',50,'',''),(49,'VI','Virgin Islands',49,'',''),(50,'VT','Vermont',48,'',''),(51,'WA','Washington',51,'',''),(52,'WI','Wisconsin',53,'',''),(53,'WV','West Virginia',52,'',''),(54,'WY','Wyoming',54,'','');
/*!40000 ALTER TABLE `states` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-08-22 22:38:57
