-- Research Paper Repository SQL
-- Description: Full schema for academic paper storage with version control and citations

-- -----------------------------
create database repository;
use  repository;

-- -----------------------------


-- -----------------------------
-- USERS
-- -----------------------------
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('author', 'reviewer', 'admin') NOT NULL
);

-- -----------------------------
-- PAPER STATUS
-- -----------------------------
CREATE TABLE PaperStatus (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name ENUM('submitted', 'under_review', 'accepted', 'rejected') NOT NULL
);

-- -----------------------------
-- PAPERS
-- -----------------------------
CREATE TABLE Papers (
    paper_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    abstract TEXT,
    keywords TEXT,
    submitter_id INT,
    submission_date DATE DEFAULT (CURRENT_DATE),
    status_id INT,
    FOREIGN KEY (submitter_id) REFERENCES Users(user_id),
    FOREIGN KEY (status_id) REFERENCES PaperStatus(status_id)
);

-- -----------------------------
-- PAPER VERSIONS
-- -----------------------------
CREATE TABLE PaperVersions (
    version_id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT,
    version_number INT,
    content TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paper_id) REFERENCES Papers(paper_id)
);

-- -----------------------------
-- CITATIONS
-- -----------------------------
CREATE TABLE Citations (
    citing_paper_id INT,
    cited_paper_id INT,
    PRIMARY KEY (citing_paper_id, cited_paper_id),
    FOREIGN KEY (citing_paper_id) REFERENCES Papers(paper_id),
    FOREIGN KEY (cited_paper_id) REFERENCES Papers(paper_id)
);

-- -----------------------------
-- REVIEWS
-- -----------------------------
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    paper_id INT,
    reviewer_id INT,
    comments TEXT,
    review_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    reviewed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paper_id) REFERENCES Papers(paper_id),
    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id)
);

-- -----------------------------
-- PERMISSIONS
-- -----------------------------
CREATE TABLE Permissions (
    role ENUM('author', 'reviewer', 'admin') PRIMARY KEY,
    can_submit BOOLEAN,
    can_review BOOLEAN,
    can_manage BOOLEAN
);

-- -----------------------------
-- TAGS (Bonus)
-- -----------------------------
CREATE TABLE Tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(50) UNIQUE
);

CREATE TABLE PaperTags (
    paper_id INT,
    tag_id INT,
    PRIMARY KEY (paper_id, tag_id),
    FOREIGN KEY (paper_id) REFERENCES Papers(paper_id),
    FOREIGN KEY (tag_id) REFERENCES Tags(tag_id)
);

-- -----------------------------
-- AUDIT LOGS (Bonus)
-- -----------------------------
CREATE TABLE AuditLogs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    performed_by INT,
    performed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES Users(user_id)
);

-- -----------------------------
-- SAMPLE DATA
-- -----------------------------
INSERT INTO Users (name, email, role) VALUES
('Alice Author', 'alice@example.com', 'author'),
('Bob Reviewer', 'bob@example.com', 'reviewer'),
('Carol Admin', 'carol@example.com', 'admin'),
('Dave Author', 'dave@example.com', 'author'),
('Eva Reviewer', 'eva@example.com', 'reviewer'),
('Frank Admin', 'frank@example.com', 'admin');

INSERT INTO PaperStatus (status_name) VALUES
('submitted'), ('under_review'), ('accepted'), ('rejected');

INSERT INTO Papers (title, abstract, keywords, submitter_id, status_id, submission_date) VALUES
('Quantum Computing Advances', 'A dive into quantum mechanics and computing.', 'quantum,computing', 4, 1, '2024-12-01'),
('Blockchain Security', 'Security flaws and strengths of blockchain systems.', 'blockchain,security', 1, 2, '2025-01-15'),
('Neural Networks Explained', 'An overview of deep learning techniques.', 'neural networks,AI', 4, 3, '2025-02-10');

-- Insert more versions
-- Ensure paper_ids 1, 2, 3 exist before inserting versions
INSERT INTO PaperVersions (paper_id, version_number, content) VALUES
(1, 1, 'First draft of Quantum Computing Advances'),
(2, 1, 'Initial Blockchain Security Paper'),
(2, 2, 'Updated with reviewer comments'),
(3, 1, 'Original Neural Networks Paper');

-- Insert citations
-- Valid citations among papers 1 to 3
INSERT INTO Citations (citing_paper_id, cited_paper_id) VALUES
(2, 1),
(3, 1),
(3, 2);

-- Insert reviews with different statuses
-- Reviewer_id 5 (Eva) and reviewer_id 2 (Bob) must exist in Users table
INSERT INTO Reviews (paper_id, reviewer_id, comments, review_status, reviewed_at) VALUES
(1, 2, 'Looks good, minor changes suggested.', 'pending','2025-01-10 10:10:00'),
(2, 5, 'Interesting concepts, but needs clarification.', 'approved', '2025-01-10 10:00:00'),
(3, 5, 'Well structured and relevant.', 'approved', '2025-01-18 14:30:00'),
(3, 5, 'Consider improving intro.', 'rejected', '2025-02-15 16:00:00');


INSERT INTO Permissions VALUES
('author', TRUE, FALSE, FALSE),
('reviewer', FALSE, TRUE, FALSE),
('admin', TRUE, TRUE, TRUE);


INSERT INTO Tags (tag_name) VALUES 
 ('Quantum'), ('Blockchain'), ('Deep Learning'),
('AI'), ('Machine Learning');

-- Only insert tags for existing papers (IDs 1, 2, 3)
INSERT INTO PaperTags VALUES 
(1, 1),  -- paper 1 → tag 1
(1, 2),  -- paper 1 → tag 2
(2, 3),  -- paper 2 → tag 3
(3, 4);  



-- -----------------------------
-- VIEW EXAMPLE
-- -----------------------------
CREATE VIEW PaperSummary AS
SELECT p.paper_id, p.title, u.name AS author, ps.status_name, pv.version_number, pv.updated_at
FROM Papers p
JOIN Users u ON p.submitter_id = u.user_id
JOIN PaperStatus ps ON p.status_id = ps.status_id
JOIN PaperVersions pv ON p.paper_id = pv.paper_id;


CREATE VIEW ReviewDashboard AS
SELECT r.review_id, u.name AS reviewer, p.title AS paper_title, r.review_status, r.reviewed_at
FROM Reviews r
JOIN Users u ON r.reviewer_id = u.user_id
JOIN Papers p ON r.paper_id = p.paper_id;
-- -----------------------------
-- STORED PROCEDURE EXAMPLE
-- -----------------------------
DELIMITER //
CREATE PROCEDURE SubmitNewVersion(IN p_id INT, IN version_num INT, IN new_content TEXT)
BEGIN
  INSERT INTO PaperVersions(paper_id, version_number, content)
  VALUES (p_id, version_num, new_content);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdatePaperStatus(IN paperId INT, IN newStatusId INT)
BEGIN
  UPDATE Papers SET status_id = newStatusId WHERE paper_id = paperId;
END //
DELIMITER ;

-- -----------------------------
-- FUNCTION EXAMPLE
-- -----------------------------
DELIMITER //
CREATE FUNCTION TotalCitations(p_id INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM Citations WHERE cited_paper_id = p_id;
  RETURN total;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION GetAuthorPaperCount(authorId INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE paperCount INT;
  SELECT COUNT(*) INTO paperCount FROM Papers WHERE submitter_id = authorId;
  RETURN paperCount;
END //
DELIMITER ;

-- -----------------------------
-- TRIGGER EXAMPLE
-- -----------------------------
DELIMITER //
CREATE TRIGGER AfterPaperInsert
AFTER INSERT ON Papers
FOR EACH ROW
BEGIN
  INSERT INTO AuditLogs(table_name, operation_type, performed_by)
  VALUES ('Papers', 'INSERT', NEW.submitter_id);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER LogReviewInsert
AFTER INSERT ON Reviews
FOR EACH ROW
BEGIN
  INSERT INTO AuditLogs(table_name, operation_type, performed_by)
  VALUES ('Reviews', 'INSERT', NEW.reviewer_id);
END //
DELIMITER ;

-- -----------------------------
-- SAMPLE QUERY EXAMPLES
-- -----------------------------
-- Get papers submitted by Alice
SELECT * FROM PaperSummary WHERE author = 'Alice Author';

-- Get citation count for a paper
SELECT TotalCitations(1) AS citation_count;

-- Get pending reviews
SELECT * FROM Reviews WHERE review_status = 'pending';

-- Show the most recent review timestamp per reviewer
SELECT reviewer_id, MAX(reviewed_at) AS last_reviewed
FROM Reviews
GROUP BY reviewer_id;

-- Show papers that cite a specific paper (paper_id = 1)
SELECT p.title FROM Citations c
JOIN Papers p ON c.citing_paper_id = p.paper_id
WHERE c.cited_paper_id = 1;

-- 1. Get authors whose papers have the highest number of citations
SELECT u.name AS author_name, p.title, COUNT(c.cited_paper_id) AS citation_count
FROM Users u
JOIN Papers p ON u.user_id = p.submitter_id
LEFT JOIN Citations c ON p.paper_id = c.cited_paper_id
GROUP BY u.name, p.title
ORDER BY citation_count DESC
LIMIT 5;

--  List all papers along with their latest version number and timestamp
SELECT p.paper_id, p.title, MAX(pv.version_number) AS latest_version, MAX(pv.updated_at) AS last_updated
FROM Papers p
JOIN PaperVersions pv ON p.paper_id = pv.paper_id
GROUP BY p.paper_id, p.title;

-- Get all papers by a specific author
SELECT * FROM Papers WHERE submitter_id = 1;
