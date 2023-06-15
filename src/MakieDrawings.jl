module MakieDrawings
using MathTeXEngine
using LaTeXStrings
using StaticArrays

using CairoMakie

function segments_from_extrema(begin_points,end_points)
    nseg = length(begin_points)
    xs = Float64[]
    ys = Float64[]
    for i ∈ 1:nseg
        push!(xs,begin_points[i][1])
        push!(xs,end_points[i][1])
        push!(xs,NaN)

        push!(ys,begin_points[i][2])
        push!(ys,end_points[i][2])
        push!(ys,NaN)
    end
    return xs,ys
end

function drawgrid_lines_and_node(ax1,nx,ny,dx,dy,ox=0.0,oy=0.0;color=:black)
    lx = (nx-1)*dx
    ly = (ny-1)*dy
    xs = range(ox,ox+lx,nx)
    ys = range(oy,oy+ly,ny)

    poly!(Rect(xs[1],ys[1],lx,ly),color=(color,0.03), transparency=true)


    #hlines
    hbp = [(xs[1 ],ys[j]) for j ∈ 1:ny]
    hep = [(xs[nx],ys[j]) for j ∈ 1:ny]
    hxs,hys = segments_from_extrema(hbp,hep)
    #vlines
    vbp = [(xs[i],ys[1 ]) for i ∈ 1:nx]
    vep = [(xs[i],ys[ny]) for i ∈ 1:nx]
    vxs,vys = segments_from_extrema(vbp,vep)
    hvxs = vcat(hxs,vxs)
    hvys = vcat(hys,vys)
    lines!(ax1,hvxs,hvys,linewidth=4,color=color)
    #circle on nodes for P
    nodes=vec([(xs[i],ys[j]) for i ∈ 1:nx, j ∈ 1:ny])
    xsn= [n[1] for n ∈ nodes]
    ysn= [n[2] for n ∈ nodes]
    scatter!(ax1,xsn,ysn,markersize=40,color=color)
    return lx,ly,xs,ys,nodes
end

function drawgrid2D(nx=4,ny=3,dx=1.0,dy=1.0)
    fig = Figure(resolution = (2000, 2000), fontsize = 72)
    title = "grid"
    # ax1 = Axis(fig[1, 1]; aspect = DataAspect(), xlabel = "x", ylabel = "y",title=title)
    ax1 = Axis(fig[1, 1]; aspect = DataAspect())
    hidedecorations!(ax1)
    hidespines!(ax1)
    #draw grid
    lx,ly,xs,ys,nodes=drawgrid_lines_and_node(ax1,nx,ny,dx,dy)

    #texts Pij
    lP(i,j) = latexstring("P_{$i,$j}")
    texts = vec([lP(i,j) for i ∈ 1:nx, j ∈ 1:ny])
    spacing=0.05
    text_positions = [(n[1]+spacing,n[2]+spacing) for n ∈ nodes ]
    text!(ax1,text_positions,text=texts,color=:blue,align=(:left,:bottom))
    # Vx Arrows
    vxs = vcat(xs,lx+dx)
    vxnodes=vec([(vxs[i]-dx/2,ys[j]) for i ∈ 1:nx+1, j ∈ 1:ny])
    xsvx= [n[1] for n ∈ vxnodes]
    ysvx= [n[2] for n ∈ vxnodes]
    vxu = [dx for n ∈ vxnodes]
    vxv = [0.0 for n ∈ vxnodes]
    scatter!(ax1,xsvx,ysvx,markersize=40,color=:red)
    arrows!(ax1,xsvx,ysvx,vxu,vxv, linewidth = 12,color=:red,lengthscale=0.15,arrowsize=50)
    # Vx texts
    lvx(i,j) = latexstring("V^X_{$i,$j}")
    vxtexts = vec([lvx(i,j) for i ∈ 1:nx+1, j ∈ 1:ny])
    spacing=0.05
    vxtext_positions = [(n[1],n[2]+spacing) for n ∈ vxnodes ]
    text!(ax1,vxtext_positions,text=vxtexts,color=:red)
    # Vy Arrows
    vys = vcat(ys,ly+dy)
    vynodes=vec([(xs[i],vys[j]-dy/2) for i ∈ 1:nx, j ∈ 1:ny+1])
    xsvy= [n[1] for n ∈ vynodes]
    ysvy= [n[2] for n ∈ vynodes]
    vyu = [0.0 for n ∈ vynodes]
    vyv = [dy for n ∈ vynodes]
    scatter!(ax1,xsvy,ysvy,markersize=40,color=:green)
    arrows!(ax1,xsvy,ysvy,vyu,vyv, linewidth = 12,color=:green,lengthscale=0.15,arrowsize=50)
    # Vy texts
    lvy(i,j) = latexstring("V^Y_{$i,$j}")
    vytexts = vec([lvy(i,j) for i ∈ 1:nx, j ∈ 1:ny+1])
    spacing=0.05
    vytext_positions = [(n[1]+spacing,n[2]) for n ∈ vynodes ]
    text!(ax1,vytext_positions,text=vytexts,color=:green)
    save("basic_grid.png",fig)
    fig
end


function drawsource2D(nx=15,ny=12,dx=0.5,dy=0.5,sxc=2.95,syc=1.85,sxr=1.2)
    fig = Figure(resolution = (2000, 2000), fontsize = 72)
    ax1 = Axis(fig[1, 1]; aspect = DataAspect())
    # hidedecorations!(ax1)
    # hidespines!(ax1)
    lx,ly,xs,ys,nodes=drawgrid_lines_and_node(ax1,nx,ny,dx,dy)
    #texts Pij
    index_font_size = 45

    lP(i,j) = latexstring("$i,$j")
    texts = vec([lP(i,j) for i ∈ 1:nx, j ∈ 1:ny])
    spacing=0.05
    text_positions = [(n[1]+spacing,n[2]+spacing) for n ∈ nodes ]
    text!(ax1,text_positions,text=texts,color=:blue,align=(:left,:bottom),fontsize=index_font_size)
    # text to the top
    scenter(sxc,syc) = latexstring("~~n_x=$nx~~n_y=$ny~~\\vec{S}_c=($sxc,$syc)~~r_s=$sxr")
    text!(ax1,(dx,ly+0.5dy),text=scenter(sxc,syc),align=(:left,:tom))
    # Source area
    scatter!(ax1,(sxc,syc),color=:black,markersize=50,marker=:xcross)
    arc!(Point2f(sxc,syc),sxr,0,2π,color=:red,linewidth=10,linestyle=:dot,fillcolor=:pink)
    # drawn Imin,Imax
    Imin=(5,3)
    Imax=(9,7)
    position(I) = xs[I[1]],ys[I[2]]
    scatter!(ax1,position(Imin),color=:black,markersize=60)
    scatter!(ax1,position(Imax),color=:black,markersize=60)
    source_node_positions = vec([position((i,j)) for i ∈ Imin[1]:Imax[1], j ∈ Imin[2]:Imax[2]])
    scatter!(ax1,source_node_positions,color=:red,markersize=40)  
    # text to the bottom
    siminpmin(sxc,syc) = latexstring("~~I_{min}=($(Imin[1]),$(Imin[2]))~~I_{max}=($(Imax[1]),$(Imax[2]))\\rightarrow n_{sx}=5~~n_{sy}=5")
    text!(ax1,(dx,-0.5dy),text=siminpmin(sxc,syc),align=(:left,:top))
    save("source_grid.png",fig)
    fig
end


function drawsensor2D(nx=10,ny=12,dx=0.5,dy=0.5,sxc=0,syc=3.1,sxr=1.22)
    fig = Figure(resolution = (2000, 2000), fontsize = 62)
    ax1 = Axis(fig[1, 1]; aspect = DataAspect())
    # hidedecorations!(ax1)
    # hidespines!(ax1)
    lx,ly,xs,ys,nodes=drawgrid_lines_and_node(ax1,nx,ny,dx,dy)
    #texts Pij
    index_font_size = 45

    lP(i,j) = latexstring("$i,$j")
    texts = vec([lP(i,j) for i ∈ 1:nx, j ∈ 1:ny])
    spacing=0.05
    text_positions = [(n[1]+spacing,n[2]+spacing) for n ∈ nodes ]
    text!(ax1,text_positions,text=texts,color=:blue,align=(:left,:bottom),fontsize=index_font_size)
    # text to the top
    pmin_y = round(syc-sxr;sigdigits=3) 
    pmax_y = round(syc+sxr;sigdigits=3) 
    scenter(sxc,syc) = latexstring("~~n_x=$nx~~n_y=$ny~~p_{min}=($sxc,$pmin_y)~~p_{max}=($(sxc+sxr),$pmax_y)")
    text!(ax1,(0,ly+0.5dy),text=scenter(sxc,syc),align=(:left,:tom))
    # Sensor area
    segment_points = [(sxc,syc-sxr),(sxc+sxr,syc-sxr),(sxc+sxr,syc+sxr),(sxc,syc+sxr)]
    segxs = first.(segment_points)
    segys = last.(segment_points)
    lines!(ax1,segxs,segys,color=:red,linewidth=10,linestyle=:dot,fillcolor=:pink)

    # scatter!(ax1,(sxc,syc),color=:black,markersize=50,marker=:xcross)
    # arc!(Point2f(sxc,syc),sxr,0,2π,color=:red,linewidth=10,linestyle=:dot,fillcolor=:pink)
    # drawn Imin,Imax
    Imin=(1,5)
    Imax=(3,9)
    position(I) = xs[I[1]],ys[I[2]]
    scatter!(ax1,position(Imin),color=:black,markersize=60)
    scatter!(ax1,position(Imax),color=:black,markersize=60)
    source_node_positions = vec([position((i,j)) for i ∈ Imin[1]:Imax[1], j ∈ Imin[2]:Imax[2]])
    scatter!(ax1,source_node_positions,color=:red,markersize=40)  
    # text to the bottom
    siminpmin(sxc,syc) = latexstring("~~I_{min}=($(Imin[1]),$(Imin[2]))~~I_{max}=($(Imax[1]),$(Imax[2]))\\rightarrow n_{sx}=3~~n_{sy}=5")
    text!(ax1,(0,-0.5dy),text=siminpmin(sxc,syc),align=(:left,:top))
    save("sensor_grid.png",fig)
    fig
end

function drawsplit(N=SVector{2,Int}(6,8),
                    Δ=SVector{2,Float64}(0.5,0.5),
                    D=SVector{2,Int}(2,2))

    S = (N .-2) .÷ D
    (S .* D) != (N .-2) && error( "$(N .-2) must be divisible my $D")
    Nl = S .+ 2 # local number of point (2 points overlap)


    fig = Figure(resolution = (3000, 2000), fontsize = 62,title="tpt")
    ax0 = Axis(fig[1, 1]; aspect = DataAspect())
    ax1 = Axis(fig[1, 2]; aspect = DataAspect())
    lx,ly,xs,ys,nodes=drawgrid_lines_and_node(ax0,N[1],N[2],Δ[1],Δ[2])
    hidedecorations!(ax1)
    hidespines!(ax1)
    hidedecorations!(ax0)
    hidespines!(ax0)

    index_font_size = 45
    #texts Pij
    lP(i,j) = latexstring("$i,$j")
    texts = vec([lP(i,j) for i ∈ 1:N[1], j ∈ 1:N[2]])
    spacing=0.05
    text_positions = [(n[1]+spacing,n[2]+spacing) for n ∈ nodes ]
    text!(ax0,text_positions,text=texts,color=:black,align=(:left,:bottom),fontsize=index_font_size)
    left_bottom_string() = latexstring("~~N=($(N[1]),$(N[2]))~~D=($(D[1]),$(D[2]))")
    text!(ax0,(Δ[1],-Δ[2]),text=left_bottom_string(),align=(:left,:bottom))


    text!(ax1,text_positions,text=texts,color=:black,align=(:left,:bottom),fontsize=index_font_size)

    ϵ =0.04
    texts = vec([lP(i,j) for i ∈ 1:Nl[1], j ∈ 1:Nl[2]])
    spacing=0.05

    lx11,ly11,xs11,ys11,nodes11=drawgrid_lines_and_node(ax1,Nl[1],Nl[2],Δ[1],Δ[2],-ϵ,-ϵ,color=:orange)  
    text!(ax1, [(n[1]-spacing,n[2]-spacing) for n ∈ nodes11 ],text=texts,color=:orange,align=(:right,:top),fontsize=index_font_size)  
    lx21,ly21,xs21,ys21,nodes21=drawgrid_lines_and_node(ax1,Nl[1],Nl[2],Δ[1],Δ[2],(Nl[1]-2)*Δ[1]+ϵ,-ϵ,color=:green)    
    text!(ax1, [(n[1]+spacing,n[2]-spacing) for n ∈ nodes21 ],text=texts,color=:green,align=(:left,:top),fontsize=index_font_size)  
    lx12,ly12,xs12,ys12,nodes12=drawgrid_lines_and_node(ax1,Nl[1],Nl[2],Δ[1],Δ[2],-ϵ,(Nl[2]-2)*Δ[1]+ϵ,color=:blue)    
    text!(ax1, [(n[1]-spacing,n[2]+spacing) for n ∈ nodes12 ],text=texts,color=:blue,align=(:right,:bottom),fontsize=index_font_size)  
    lx22,ly22,xs22,ys22,nodes22=drawgrid_lines_and_node(ax1,Nl[1],Nl[2],Δ[1],Δ[2],(Nl[1]-2)*Δ[1]+ϵ,(Nl[2]-2)*Δ[1]+ϵ,color=:red)   
    text!(ax1, [(n[1]+spacing,n[2]+2spacing) for n ∈ nodes22 ],text=texts,color=:red,align=(:left,:bottom),fontsize=index_font_size)  


    bottom_string() = latexstring("~N_l=[~(N-2)\\div D~]+2=($(Nl[1]),$(Nl[2]))")
    text!(ax1,(Δ[1],-Δ[2]),text=bottom_string(),align=(:left,:tom))
    save("split_grid.png",fig)


    fig
end




end # module
