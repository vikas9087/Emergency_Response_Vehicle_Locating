using JuMP, Gurobi,DataFrames,CSV;
EMS=Model(solver=GurobiSolver());
#Defining the data
nr_base=3;
nr_fire=3;
nr_med=3;
pr_fire=[1,1,1,1,2,1,1,2,3,2,1,1];
pr_med=[1,2,1,1,2,1,2,2,3,2,1,1];
pr_node=pr_fire+pr_med;
N=2;
file_path="F:/Clemson/Sem 2/IE 6850/Assignment/Project/distance.csv"
distance=CSV.read(file_path);
EP=(1=>2,2=>4,3=>7,4=>10,5=>16,6=>21,7=>23,8=>25,9=>26,10=>32,11=>42,12=>44)
#number of potential bases
J=length(distance[:,1]);
#numbder of emergency sites
I=length(distance)-1;

#defining variable for bases to open
@variable(EMS,y[1:J],Bin);
#Defining variable for points i to serve by base j
@variable(EMS,x[1:J,1:I],Bin);

@objective(EMS,Max,sum(pr_node[i]*x[j,i] for j=1:J,i=1:I));

for i=1:I
@constraint(EMS,sum(x[j,i] for j=1:J)<=1)
end

#Constraint for number of bases to open
@constraint(EMS,sum(y[j] for j=1:J)==nr_base);

#coverage distance constraint
for j in 1:J;
    for i in 1:I;
        @constraint(EMS,sum(distance[j,i+1]*x[j,i])<=N*y[j])
    end
end
status=solve(EMS)
print(getobjectivevalue(EMS))
Bases=getvalue(y);
for j=1:J;
    if Bases[j]!=0
        println("Bases to open ",distance[j,1],"= ",Bases[j])
    else
    end
end
service=getvalue(x);
for j=1:J;
    for i=1:I;
        if service[j,i]!=0
            println("Emergency base ",distance[j,1]," covers emergency point ",EP[i],"= ",service[j,i])
        else
        end
    end
end
