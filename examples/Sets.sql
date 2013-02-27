use downing_test;

# ---------
# set union
# ---------

# names of students OR colleges

# project[cName]
#     (Student)
# union
# project[sName]
#     (College)

(select cName from College)
union
(select sName from Student)
order by cName;

(select cName as name from College)
union
(select sName as name from Student)
order by name;

# ----------------
# set intersection
# ----------------

# names of students AND colleges

# project[sName]
#     (Student)
# intersect
# project[cName]
#     (College)

# mysql doesn't support 'intersect'

# using a subquery, with exists

select cName as name
    from College
    where exists
        (select *
            from Student
            where cName = sName);

# using join

select * from
    (select sName as name from Student) as R
    natural join
    (select cName as name from College) as S;

# --------------
# set difference
# --------------

# ID of students who didn't apply anywhere

# project[sID]
#     (Student)
# diff
# project[sID]
#     (Apply)

# mysql doesn't support 'except'

# using a subquery, with not in

select sID as name
    from Student
    where sID not in
        (select sID
            from Apply)
    order by sID;

# using a subquery, with not exists

select sID
    from Student
    where not exists
        (select *
            from Apply
            where Student.sID = Apply.sID)
    order by sID;

# ------
# rename
# ------

# pairs of names of colleges in the same state

# project[cName1, cName2] (
#     select[cName1 != cName2]
#         rename[cName1, state, enrollment1]
#             (College);
#         join
#         rename[cName2, state, enrollment2]
#             (College);

# this isn't right
# because of duplicates

select cName1, cName2
    from
        (select cName as cName1, state, enrollment as enrollment1
            from College) as R
        natural join
        (select cName as cName2, state, enrollment as enrollment2
            from College) as S
    where cName1 != cName2;

# this is right

select cName1, cName2
    from
        (select cName as cName1, state, enrollment as enrollment1
            from College) as R
        natural join
        (select cName as cName2, state, enrollment as enrollment2
            from College) as S
    where cName1 < cName2;

# colleges with enrollments < 20000 that Amy OR Irene applied to

# project[cName](
#   select[(sName = 'Amy') and (enrollment < 20000)]
#   (Student join Apply join College))
# union
# project[cName](
#   select[(sName = 'Irene') and (enrollment < 20000)]
#   (Student join Apply join College))

# select[((sName = 'Amy') or (sName = 'Irene')) and (enrollment < 20000)]
#     (Student join Apply join College)

select *
    from Student natural join Apply natural join College
    where ((sName = 'Amy') or (sName = 'Irene')) and (enrollment < 20000)
    order by cName;

# project[cName](
#     select[((sName = 'Amy') or (sName = 'Irene')) and (enrollment < 20000)]
#         (Student join Apply join College))

select distinct cName
    from Student natural join Apply natural join College
    where (((sName = 'Amy') or (sName = 'Irene')) and (enrollment < 20000))
    order by cName;

# colleges with enrollments < 20000 that Amy AND Irene applied to

# project[cName](
#   select[(sName = 'Amy') and (enrollment < 20000)]
#   (Student join Apply join College))
# intersect
# project[cName](
#   select[(sName = 'Irene') and (enrollment < 20000)]
#   (Student join Apply join College))

select *
    from
        (select distinct cName from
            Student natural join Apply natural join College
            where ((sName = 'Amy') and (enrollment < 20000))) as R
        natural join
        (select distinct cName from
            Student natural join Apply natural join College
            where ((sName = 'Irene') and (enrollment < 20000))) as S;

exit
