CREATE TABLE `shop_inventory` (
  `shopId` varchar(100) NOT NULL,
  `pid` varchar(45) NOT NULL,
  `quantity` int DEFAULT NULL,
  PRIMARY KEY (`shopId`,`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
