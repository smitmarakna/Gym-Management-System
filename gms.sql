-- GYM MANAGEMENT SYSTEM 
create database GMS;

use GMS;
SET SQL_SAFE_UPDATES = 0;
create table MembershipType(
	MembershipTypeID INT PRIMARY KEY AUTO_INCREMENT,
    TypeName VARCHAR(50) NOT NULL,
    DurationInMonths INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);
select TypeName from membershiptype;
INSERT INTO MembershipType (TypeName, DurationInMonths, Price)
VALUES 
    ('Monthly', 1, 3000.00),
    ('Quarterly', 3, 6000.00),
    ('Annual', 12, 15000.00),
    ('Personal training quaterly', 3, 10000.00),
	('Personal training Annualy', 12, 30000.00);

create table Members(
	MemberID int primary key auto_increment,
    Name varchar(100) not null,
    PhoneNumber varchar(25),
    Address varchar(250),
    MembershipTypeID int,
    JoinDate date,
    foreign key (MembershipTypeID) references MembershipType(MembershipTypeID)
);
INSERT INTO Members (Name, PhoneNumber, Address, MembershipTypeID, JoinDate)
VALUES 
    ('John Doe', '1234567890', '123 Main St', 1, '2024-01-15'),
    ('Jane Smith', '2345678901', '456 Park Ave', 2, '2024-02-20'),
    ('Alice Johnson', '3456789012', '789 Elm St', 3, '2024-03-10');
    
update members set JoinDate = '2024-01-15' where memberid =1;
create table Trainers(
	TrainerID int primary key auto_increment,
    Name varchar(100) not null,
    Speciality varchar(100),
    ContactInfo varchar(100)
);
select * from trainers;
INSERT INTO Trainers (Name, Speciality, ContactInfo)
VALUES 
    ('Tom Brown', 'Weight Training', 'tom@example.com'),
    ('Sarah White', 'Yoga', 'sarah@example.com'),
    ('Mike Black', 'Cardio', 'mike@example.com'),
    ('Jack Medow', 'Powerlifting', 'Jack@example.com'),
    ('Jane Jonshon', 'Weight Loss', 'jane@example.com');


create table Payments(
	PaymentID int Primary key auto_increment,
    MemberID int,
    AmountPaid decimal(10,2) not null,
    MembershipTypeID int,
    PaymentDate date not null,
    PaymentStatus varchar(100) not null,
    foreign key (MemberID) references Members(MemberID),
    foreign key (MembershipTypeID) references MembershipType(MembershipTypeID)
);

INSERT INTO Payments (MemberID, AmountPaid, MembershipTypeID, PaymentDate, PaymentStatus)
VALUES
    (1, 3000.00, 1, '2024-01-15', 'Paid'),
    (2, 15000.00, 3, '2024-02-20', 'Paid'),
    (3, 10000.00, 4, '2024-03-10', 'Paid');

create table WorkoutSchedules(
	ScheduleID int primary key auto_increment,
    MemberID int,
    trainerID int,
    ScheduleDate date,
    TimeSlot time,
    foreign key (MemberID) references Members(MemberID),
    foreign key (trainerID) references Trainers(TrainerID)
);
INSERT INTO WorkoutSchedules (MemberID, TrainerID, ScheduleDate, TimeSlot)
VALUES 
    (1, 1, '2024-04-01', '08:00:00'),
    (2, 5, '2024-04-02', '09:00:00'),
    (3, 3, '2024-04-03', '10:00:00');
    
create table Classes(
	CLassID INT PRIMARY KEY AUTO_INCREMENT,
    ClassName VARCHAR(100) NOT NULL,
    TrainerID INT,
    ClassDate DATE,
    TimeSlot TIME,
    FOREIGN KEY (TrainerID) REFERENCES Trainers(TrainerID)
);

INSERT INTO Classes (ClassName, TrainerID, ClassDate, TimeSlot)
VALUES 
    ('Yoga', 2, '2024-04-05', '08:00:00'),
    ('HIIT', 1, '2024-04-06', '09:00:00'),
    ('Zumba Class', 3, '2024-04-07', '10:00:00'),
    ('Spin Class', 3, '2024-04-08', '9:00:00');
    
create table ClassBooking(
	BookingID int primary key auto_increment,
    MemberID int,
    ClassID int,
    foreign key (MemberID) references Members(MemberID),
    foreign key (ClassID) references CLasses(ClassID)
);

INSERT INTO ClassBooking (MemberID, ClassID)
VALUES 
    (1, 4),
    (2, 1),
    (3, 3);
    
-- view 1 Active members

create view ActiveMembers as
select m.MemberID, m.Name as MemberName, mt.TypeName as MembershipType, mt.DurationInMonths , m.JoinDate, 
	   date_add(m.JoinDate, interval mt.DurationInMonths month) as ExpiryDate,
       datediff(DATE_ADD(m.JoinDate, INTERVAL mt.DurationInMonths MONTH), CURDATE()) as daysRemaining
from Members m
join MembershipType mt on m.MembershipTypeID = mt.MembershipTypeID
where datediff(DATE_ADD(m.JoinDate, INTERVAL mt.DurationInMonths MONTH), CURDATE()) > 0;

select * from ActiveMembers;

-- view 2 schedule of trainers  
create view TrainerSchedule as 
select t.trainerid, t.name as TrainerName, ws.memberid, ws.scheduledate, ws.timeslot
from trainers t
join workoutschedules ws on t.trainerid = ws.trainerid
order by t.TrainerID, ws.ScheduleDate, ws.TimeSlot;

select * from trainerschedule;

-- procedures
DELIMITER //
CREATE PROCEDURE AddMember(
    IN memberName VARCHAR(100),
    IN phone VARCHAR(15),
    IN address VARCHAR(255),
    IN membershipTypeID INT,
    IN joinDate DATE
)
BEGIN
    INSERT INTO Members (Name, PhoneNumber, Address, MembershipTypeID, JoinDate)
    VALUES (memberName, phone, address, membershipTypeID, joinDate);
END //
DELIMITER ;

SELECT * FROM MEMBERS;
drop procedure processpayment;
DELIMITER //
CREATE PROCEDURE ProcessPayment(
	in memberID int,
    in amount decimal(10,2),
    in membershipTypeID int,
    in paymentDate date,
    in paymentStatus varchar(50)
)
begin
	insert into payments(MemberID, AmountPaid, membershipTypeID, PaymentDate, PaymentStatus)
    values (memberID, amount, membershipTypeID, paymentDate, paymentStatus);
end //
delimiter ;


-- TRIGGERS
ALTER TABLE Members ADD ActiveStatus ENUM('Active', 'Expired') DEFAULT 'Active';

DELIMITER //
CREATE TRIGGER UpdateMembershipStatus
AFTER UPDATE ON Members
FOR EACH ROW
BEGIN
    DECLARE expiryDate DATE;
    SET expiryDate = DATE_ADD(NEW.JoinDate, INTERVAL (SELECT DurationInMonths FROM MembershipType WHERE MembershipTypeID = NEW.MembershipTypeID) MONTH);
    
    IF CURDATE() > expiryDate THEN
        UPDATE Members SET ActiveStatus = 'Expired' WHERE MemberID = NEW.MemberID;
    ELSE
        UPDATE Members SET ActiveStatus = 'Active' WHERE MemberID = NEW.MemberID;
    END IF;
END //
DELIMITER ;
DELIMITER //
drop trigger UpdateMembershipStatus;
CREATE TRIGGER PaymentStatusUpdate
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    IF (SELECT ActiveStatus FROM Members WHERE MemberID = NEW.MemberID) = 'Expired' THEN
        UPDATE Members SET ActiveStatus = 'Active', JoinDate = NEW.PaymentDate WHERE MemberID = NEW.MemberID;
    END IF;
END //
DELIMITER ;

SELECT * FROM MEMBERS;