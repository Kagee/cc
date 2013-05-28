-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- Vert: localhost
-- Generert den: 28. Mai, 2013 02:48 AM
-- Tjenerversjon: 5.5.29
-- PHP-Versjon: 5.3.10-1ubuntu3.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT=0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `cc_sort`
--
DROP DATABASE `cc_sort`;
CREATE DATABASE `cc_sort` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `cc_sort`;

DELIMITER $$
--
-- Prosedyrer
--
DROP PROCEDURE IF EXISTS `p_val_recipe`$$
CREATE DEFINER=`ftb`@`localhost` PROCEDURE `p_val_recipe`(
    IN      target_id	INT(8)
,   IN      target_meta	INT(8)
,   IN      target_amount INT(8)
,   IN      id	INT(8)
,   IN      meta	INT(8)
,   IN      amount	INT(8)
)
    NO SQL
    DETERMINISTIC
_main: BEGIN
	DECLARE ERR_AM_LOW CONDITION FOR SQLSTATE '45000';
    IF target_amount < 1 OR amount < 1 THEN
        SIGNAL ERR_AM_LOW
        SET MESSAGE_TEXT = 'The target or source amount is less than 1';
    ELSEIF target_id = id AND target_meta = meta THEN
        SIGNAL ERR_AM_LOW
        SET MESSAGE_TEXT = 'Target and source items are the same.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `blockdata`
--

DROP TABLE IF EXISTS `blockdata`;
CREATE TABLE IF NOT EXISTS `blockdata` (
  `id` int(8) NOT NULL,
  `meta` int(8) NOT NULL,
  `type` enum('NORMAL','MULTI','CHARGE') NOT NULL DEFAULT 'NORMAL',
  `name` varchar(50) NOT NULL,
  `shortname` varchar(5) NOT NULL,
  `amount` int(8) NOT NULL DEFAULT '0',
  UNIQUE KEY `uni_name` (`name`),
  UNIQUE KEY `uni_shortname` (`shortname`),
  UNIQUE KEY `uni_id_meta` (`id`,`meta`),
  KEY `meta` (`meta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dataark for tabell `blockdata`
--

INSERT INTO `blockdata` (`id`, `meta`, `type`, `name`, `shortname`, `amount`) VALUES
(30478, 1, 'CHARGE', 'Advanced Diamond Drill', 'ADD', 0),
(751, 1280, 'MULTI', 'Blue Alloy Wire', 'BAW', 0),
(4, 0, 'NORMAL', 'Cobblestone', 'COBB', 60),
(264, 0, 'NORMAL', 'Diamond', 'DIA', 1),
(736, 3, 'MULTI', 'Filter', 'FILT', 0),
(69, 0, 'NORMAL', 'Lever', 'LEV', 0),
(331, 0, 'NORMAL', 'Redstone', 'REDST', 45),
(21302, 0, 'CHARGE', 'Rock Cutter', '', 0),
(30218, 0, 'NORMAL', 'Rubber', 'RUBB', 0),
(280, 0, 'NORMAL', 'Stick', 'STI', 64),
(1, 0, 'NORMAL', 'Stone', 'STO', 0),
(30188, 0, 'NORMAL', 'UU-Matter', 'UU', 0);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `recipe`
--

DROP TABLE IF EXISTS `recipe`;
CREATE TABLE IF NOT EXISTS `recipe` (
  `target_id` int(8) NOT NULL,
  `target_meta` int(8) NOT NULL,
  `target_amount` int(8) NOT NULL,
  `id` int(8) NOT NULL,
  `meta` int(8) NOT NULL,
  `amount` int(8) NOT NULL,
  PRIMARY KEY (`target_id`,`target_meta`,`target_amount`,`id`,`meta`,`amount`),
  KEY `target_meta` (`target_id`,`target_meta`),
  KEY `target_meta_2` (`id`,`meta`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dataark for tabell `recipe`
--

INSERT INTO `recipe` (`target_id`, `target_meta`, `target_amount`, `id`, `meta`, `amount`) VALUES
(69, 0, 1, 4, 0, 1),
(69, 0, 1, 280, 0, 1);

--
-- Triggere `recipe`
--
DROP TRIGGER IF EXISTS `min_am_ins`;
DELIMITER //
CREATE TRIGGER `min_am_ins` BEFORE INSERT ON `recipe`
 FOR EACH ROW BEGIN
    CALL p_val_recipe(
	NEW.target_id,
	NEW.target_meta,
        NEW.target_amount,
	NEW.id,
	NEW.meta,
	NEW.amount 
    );
END
//
DELIMITER ;
DROP TRIGGER IF EXISTS `min_am_upd`;
DELIMITER //
CREATE TRIGGER `min_am_upd` BEFORE UPDATE ON `recipe`
 FOR EACH ROW BEGIN
    CALL p_val_recipe(
	NEW.target_id,
	NEW.target_meta,
        NEW.target_amount,
	NEW.id,
	NEW.meta,
	NEW.amount 
    );
END
//
DELIMITER ;

--
-- Begrensninger for dumpede tabeller
--

--
-- Begrensninger for tabell `recipe`
--
ALTER TABLE `recipe`
  ADD CONSTRAINT `id_meta_pair_must_exsist` FOREIGN KEY (`id`, `meta`) REFERENCES `blockdata` (`id`, `meta`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_meta_pair_must_exsist2` FOREIGN KEY (`target_id`, `target_meta`) REFERENCES `blockdata` (`id`, `meta`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
