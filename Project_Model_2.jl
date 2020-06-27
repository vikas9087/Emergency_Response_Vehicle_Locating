using JuMP, Gurobi,DataFrames,CSV;
EMS=Model(solver=GurobiSolver());
#Defining the data
nr_base=3;
nr_fire=5;
nr_med=5;
pr_fire=[1,1,1,1,2,1,1,2,3,2,1,1];
pr_med=[1,2,1,1,2,1,2,2,3,2,1,1];
pr_node=pr_fire+pr_med;
N=2;
file_path="F:/Clemson/Sem 2/IE 6850/Assignment/Project/distance.csv";
distance=CSV.read(file_path);
EP=(1=>2,2=>4,3=>7,4=>10,5=>16,6=>21,7=>23,8=>25,9=>26,10=>32,11=>42,12=>44);
#number of potential bases

J=length(distance[:,1]);
#numbder of emergency sites
I=length(distance)-1;

#variable for facility to open
@variable(EMS,y[1:J],Bin);
#varaible for fire vehcile allocation at j
@variable(EMS,w[1:J],Bin);
#varaible for med vehcile allocation at j
@variable(EMS,z[1:J],Bin);
#varaible for fire vehcile located at j covering point i
@variable(EMS,x[1:J,1:I],Bin);
#varaible for med vehcile located at j covering point i
@variable(EMS,u[1:J,1:I],Bin);

#defining the objective
@objective(EMS,Min,sum(pr_fire[i]*pr_fire[i]-pr_fire[i]*sum(x[j,i] for j=1:J) for i=1:I)+sum(pr_med[i]*pr_med[i]-pr_med[i]*sum(u[j,i] for j=1:J) for i=1:I));

#constraint for number of fire vehcile availble
for j in 1:J
    @constraint(EMS,sum(w[j])<=nr_fire*y[j])
end
#constraint for number of med vehcile availble
for j in 1:J
    @constraint(EMS,sum(z[j])<=nr_med*y[j])
end
#constraint for number of bases to open
@constraint(EMS,sum(y[j] for j=1:J)==nr_base);
#distance constraint for fire vechile
for i in 1:I
    for j in 1:J
        @constraint(EMS,distance[j,i+1]*x[j,i]<=N*w[j])
    end
end
#distance constraint for med vechile
for i in 1:I
    for j in 1:J
        @constraint(EMS,distance[j,i+1]*u[j,i]<=N*z[j])
    end
end
#constraint for supply demand for fire
for i in 1:I
    @constraint(EMS,sum(x[j,i] for j=1:J)<=pr_fire[i])
end
#constraint for supply demand for med
for i in 1:I
    @constraint(EMS,sum(u[j,i] for j=1:J)<=pr_med[i])
end
status=solve(EMS)
#for base to open
println("Total penalty to be levied= ",getobjectivevalue(EMS))
Bases=getvalue(y);
for j=1:J;
    if Bases[j]!=0
        println("Bases to open ",distance[j,1],"= ",Bases[j])
    else
    end
end
#for fire vechile allocation
Bases=getvalue(w);
for j=1:J
    if Bases[j]!=0
    println("Fire vehcile to be located at ",distance[j,1],"= ",Bases[j])
else
end
end
#for med vechile allocation
Bases=getvalue(z);
for j=1:J
    if Bases[j]!=0
    println("Med vehcile to be located at ",distance[j,1],"= ",Bases[j])
else
end
end

#total fire vehcile at a point
fire=getvalue(x);
for i in 1:I
    println("Fire vechile at point", EP[i],"= ",sum(fire[j,i] for j=1:J))
end

#total med vehcile at a point
fire=getvalue(u);
#total vehciles at a point
for i in 1:I
    println("Med vechile at point", EP[i],"= ",sum(fire[j,i] for j=1:J))
end
