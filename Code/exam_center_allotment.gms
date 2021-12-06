$ title Exam center allotment
* - Nikitha, Shreya

Sets
s Students 
e Centers 
c Cities ;
Alias(e, ee);
Alias(s, ss);

Parameter
center_vs_city(e,c) whether center(e) is in city(c);

$onecho > tasks1.txt
dset = e rng = a1 rdim =1
dset = c rng = a1 cdim = 1
par = center_vs_city rng= Sheet1!a1 rdim=1 cdim = 1
$offecho

$call GDXXRW center_vs_city.xlsx trace =3 @tasks1.txt
$GDXIN center_vs_city.gdx
$LOAD e c
$LOADDC  center_vs_city
$GDXIN

Parameter
citywise_preference_table(s,c) preference of each student(s) for each city(c);

$onecho > tasks2.txt
dset = s rng = a1 rdim =1
par = citywise_preference_table rng= Sheet1!a1 rdim=1 cdim = 1
$offecho

$call GDXXRW citywise_preference_table.xlsx trace =3 @tasks2.txt
$GDXIN citywise_preference_table.gdx
$LOAD s
$LOADDC citywise_preference_table
$GDXIN

Parameter
class(s) class of student(s)
     
$onecho > tasks3.txt
par = class rng= Sheet1!a1 rdim=1
$offecho

$call GDXXRW class.xlsx trace =3 @tasks3.txt
$GDXIN class.gdx
$LOADDC class
$GDXIN

Parameter     
capacity(e) Capacity of center(e)

$onecho > tasks4.txt
par = capacity rng= Sheet1!a1 rdim=1
$offecho

$call GDXXRW capacity.xlsx trace =3 @tasks4.txt
$GDXIN capacity.gdx
$LOADDC capacity
$GDXIN

Parameter
rating(e) Rating of center(e)

$onecho > tasks5.txt
par = rating rng= Sheet1!a1 rdim=1
$offecho

$call GDXXRW rating.xlsx trace = 3 @tasks5.txt
$GDXIN rating.gdx
$LOADDC rating
$GDXIN

Parameter
center_preference_table(s, e) preference of each student (s) for each center (e),
center_vs_center_superiority(e, ee) whether or not center (e) is superior to center (ee) and centers e and ee are in the same city,
city_class_preference_comparision(s, ss, c) whether or not student (s) has lower or equal preference for city (c) as student (ss) and has a lower class as student (ss),
number_of_centers_in_city_of_this_center(e);

* calculate center_preference_table
center_preference_table(s, e) = sum((c), citywise_preference_table(s,c)*center_vs_city(e,c));

* calculate center_vs_center_superiority
center_vs_center_superiority(e, ee) =  sum((c), center_vs_city(e,c)*center_vs_city(ee,c));
center_vs_center_superiority(e, ee)$(rating(e)-rating(ee)<=0) = 0;

* calculate city_class_preference_comparision
city_class_preference_comparision(s, ss, c)$((citywise_preference_table(s,c) <= citywise_preference_table(ss,c)) and citywise_preference_table(s,c)>0 and citywise_preference_table(ss,c)>0 and (class(s) < class(ss)))= 1;

number_of_centers_in_city_of_this_center(e) = sum((c), sum((ee), center_vs_city(ee,c))*center_vs_city(e,c));

Binary Variables
student_vs_allotted_center(s, e) whether center (e) is allotted to student (s),
student_vs_allotted_city(s, c) whether center (e) is allotted to student (s),
is_center_in_use(e) whether or not any student is allotted this center,
should_be_vacant(e) whether superiority constraint requires center e to be vacant or not,
student_vs_allotted_city_center(s, c, e) whether center (e) of city c is allotted to student (s) (helper variable);

Scalar large_value, small_value, number_of_preferences_taken, number_of_classes, alpha;
large_value = 1000000;
small_value = power(10, -6);
number_of_preferences_taken = 3;
number_of_classes = 4;
alpha = 1000;

Variable
number_of_centers_in_use total number of centers in use after allotment is complete,
Objective_value; 

Integer Variable
preference_city_allotted(s) prefrence of student s for the center it is allotted,
rating_center_allotted(s);

* A student should not be allotted a center in any city beyond the 3 cities which he has chosen
preference_city_allotted.lo(s) = 1;

Equations
constraint_1(s) Only one center should be allotted to each student,
constraint_2(e) No.of students allotted to a particular center <= Capacity of that center

constraint_3_1(e, ee)
constraint_3_2(e, ee)
constraint_3_3(e)

constraint_4_1(s, e, c)
constraint_4_2(s, e, c)
constraint_4_3(s, c)

constraint_5_1(s, c)
constraint_5_2(s, c)
constraint_5_3(s, ss, c)

constraint_6_1(s, e)
constraint_6_2(s, e)
constraint_6_3(s, ss, c)

constraint_7_1(e)
constraint_7_2(e)
constraint_7_3

objective_function;

* Only one center should be allotted to each  student
constraint_1(s).. sum((e), student_vs_allotted_center(s, e)) =e= 1;

* No.of students allotted to a particular center <= Capacity of that center
constraint_2(e).. sum((s), student_vs_allotted_center(s, e)) =l= capacity(e);

* Inferior centers shouldnt be allotted students when superior centers are available

* sets should_be_vacant(e) imposed by center superiority constarint
* small_value <= 1/(max_cap(e)*10)
constraint_3_1(e, ee).. small_value*(capacity(e) - sum((s), student_vs_allotted_center(s, e))) + center_vs_center_superiority(e, ee) =l= should_be_vacant(ee) + 1;
constraint_3_2(e, ee).. (1+small_value)*should_be_vacant(ee) =l= small_value*(capacity(e) - sum((s), student_vs_allotted_center(s, e))) + center_vs_center_superiority(e, ee);

* Penalises the cases when center e should have been vacant as imposed by center superiority constraint but still is allotted some students
* large_value >= max_cap(e)
constraint_3_3(e).. sum((s), student_vs_allotted_center(s, e)) =l= (1- should_be_vacant(e))*large_value;

* calculates student_vs_allotted_city(s, c)
constraint_4_1(s, e, c).. student_vs_allotted_center(s, e) + center_vs_city(e,c) -1 =l= student_vs_allotted_city_center(s, c, e);
constraint_4_2(s, e, c).. student_vs_allotted_city_center(s, c, e)*2 - 1 =l= student_vs_allotted_center(s, e) + center_vs_city(e,c) -1;
constraint_4_3(s, c).. student_vs_allotted_city(s, c) =e= sum((e), student_vs_allotted_city_center(s, c, e));

* Ensures that prioritized class students are allotted their best priority

* sets prefrence_city_allotted(s)
* large_value = 10*number_of_preferences_taken 
constraint_5_1(s, c).. citywise_preference_table(s, c) + number_of_preferences_taken*(student_vs_allotted_city(s, c) - 1) =l= preference_city_allotted(s);
constraint_5_2(s, c).. preference_city_allotted(s) + (student_vs_allotted_city(s, c) - 1)*large_value =l= citywise_preference_table(s, c) + number_of_preferences_taken*(student_vs_allotted_city(s, c) - 1);

* Ensures that prioritized class students are allotted their first priority
constraint_5_3(s, ss, c).. 0.1*((preference_city_allotted(s) - citywise_preference_table(s, c))/number_of_preferences_taken) + city_class_preference_comparision(s, ss, c) - student_vs_allotted_city(s, c) + student_vs_allotted_city(ss, c) =l= 2;

* sets rating_center_allotted(s)
* large_value = 10*number_of_centers_in_city_of_this_center(e) 
constraint_6_1(s, e).. rating(e) + number_of_centers_in_city_of_this_center(e)*(student_vs_allotted_center(s, e) - 1) =l= rating_center_allotted(s);
constraint_6_2(s, e).. rating_center_allotted(s) + (student_vs_allotted_center(s, e) - 1)*large_value =l= rating(e) + number_of_centers_in_city_of_this_center(e)*(student_vs_allotted_center(s, e) - 1);

* prioritized student should be given superior center if available
* small_value = 1/(max_class*max_number_of_centers_in_city_of_this_center*10)
constraint_6_3(s, ss, c).. (class(ss)- class (s))*(rating_center_allotted(ss) - rating_center_allotted(s))*small_value  + student_vs_allotted_city(s, c) + student_vs_allotted_city(ss, c)  =l= 2;

*For updating whether a particular center in in use or not
* large_value >= max_cap(e)
constraint_7_1(e).. sum((s), student_vs_allotted_center(s, e)) =l= is_center_in_use(e)*large_value;
constraint_7_2(e).. is_center_in_use(e) =l= sum((s), student_vs_allotted_center(s, e));
constraint_7_3.. number_of_centers_in_use =e= sum((e), is_center_in_use(e));

*objective_function.. number_of_centers =e= sum((e), is_center_in_use(e));
*alpha = total_number_of_centeres_over_all_cities*10
* to be added in report
objective_function.. Objective_value =e= number_of_centers_in_use + sum((s),  (preference_city_allotted(s)-1)*((number_of_classes + 1)-class(s))*alpha);

Model exam_center_allotment /all/;

Solve exam_center_allotment using mip minimizing Objective_value;

display student_vs_allotted_center.l;
display student_vs_allotted_city.l;
display preference_city_allotted.l;
display rating_center_allotted.l;
display number_of_centers_in_use.l;

* import results to excel sheet
execute_unload "results.gdx" student_vs_allotted_center.l
execute 'gdxxrw.exe results.gdx o=student_vs_allotted_center.xlsx var=student_vs_allotted_center.l'