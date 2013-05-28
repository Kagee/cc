SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `cc_sort` ;
CREATE SCHEMA IF NOT EXISTS `cc_sort` DEFAULT CHARACTER SET latin1 ;
USE `cc_sort` ;

-- -----------------------------------------------------
-- Table `cc_sort`.`blockdata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cc_sort`.`blockdata` ;

CREATE  TABLE IF NOT EXISTS `cc_sort`.`blockdata` (
  `id` INT(8) NOT NULL ,
  `meta` INT(8) NOT NULL ,
  `type` ENUM('NORMAL','MULTI','CHARGE') NOT NULL DEFAULT 'NORMAL' ,
  `name` VARCHAR(50) NOT NULL ,
  `shortname` VARCHAR(5) NOT NULL ,
  `amount` INT(8) NOT NULL DEFAULT '0' )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `uni_name` ON `cc_sort`.`blockdata` (`name` ASC) ;

CREATE UNIQUE INDEX `uni_shortname` ON `cc_sort`.`blockdata` (`shortname` ASC) ;

CREATE UNIQUE INDEX `uni_id_meta` ON `cc_sort`.`blockdata` (`id` ASC, `meta` ASC) ;


-- -----------------------------------------------------
-- Table `cc_sort`.`recipe`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cc_sort`.`recipe` ;

CREATE  TABLE IF NOT EXISTS `cc_sort`.`recipe` (
  `target_id` INT(8) NOT NULL ,
  `target_meta` INT(8) NOT NULL ,
  `target_amount` INT(8) NOT NULL ,
  `id` INT(8) NOT NULL ,
  `meta` INT(8) NOT NULL ,
  `amount` INT(8) NOT NULL ,
  PRIMARY KEY (`target_id`, `target_meta`, `target_amount`, `id`, `meta`, `amount`) ,
  CONSTRAINT `id_meta_pair_must_exsist`
    FOREIGN KEY (`id` , `meta` )
    REFERENCES `cc_sort`.`blockdata` (`id` , `meta` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_meta_pair_must_exsist2`
    FOREIGN KEY (`target_id` , `target_meta` )
    REFERENCES `cc_sort`.`blockdata` (`id` , `meta` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `target_meta` ON `cc_sort`.`recipe` (`target_id` ASC, `target_meta` ASC) ;

CREATE INDEX `target_meta_2` ON `cc_sort`.`recipe` (`id` ASC, `meta` ASC) ;


-- -----------------------------------------------------
-- Table `cc_sort`.`sort`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cc_sort`.`sort` ;

CREATE  TABLE IF NOT EXISTS `cc_sort`.`sort` (
  `id` INT(8) NOT NULL ,
  `meta` INT(8) NOT NULL ,
  `direction` ENUM('0','1','2','3','4','5') NOT NULL ,
  PRIMARY KEY (`id`, `meta`) ,
  CONSTRAINT `id_meta_must_exsist`
    FOREIGN KEY (`id` , `meta` )
    REFERENCES `cc_sort`.`blockdata` (`id` , `meta` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `id_meta_must_exsist` ON `cc_sort`.`sort` (`id` ASC, `meta` ASC) ;


-- -----------------------------------------------------
-- procedure p_val_recipe
-- -----------------------------------------------------

USE `cc_sort`;
DROP procedure IF EXISTS `cc_sort`.`p_val_recipe`;

DELIMITER $$
USE `cc_sort`$$
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
USE `cc_sort`;

DELIMITER $$

USE `cc_sort`$$
DROP TRIGGER IF EXISTS `cc_sort`.`min_am_ins` $$
USE `cc_sort`$$


CREATE
DEFINER=`ftb`@`localhost`
TRIGGER `cc_sort`.`min_am_ins`
BEFORE INSERT ON `cc_sort`.`recipe`
FOR EACH ROW
BEGIN
    CALL p_val_recipe(
	NEW.target_id,
	NEW.target_meta,
        NEW.target_amount,
	NEW.id,
	NEW.meta,
	NEW.amount 
    );
END$$


USE `cc_sort`$$
DROP TRIGGER IF EXISTS `cc_sort`.`min_am_upd` $$
USE `cc_sort`$$


CREATE
DEFINER=`ftb`@`localhost`
TRIGGER `cc_sort`.`min_am_upd`
BEFORE UPDATE ON `cc_sort`.`recipe`
FOR EACH ROW
BEGIN
    CALL p_val_recipe(
	NEW.target_id,
	NEW.target_meta,
        NEW.target_amount,
	NEW.id,
	NEW.meta,
	NEW.amount 
    );
END$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
