module ObsidianDocumenter

export obsidian_makedocs
import Documenter

"""
    obsidian_makedocs(; cleanup = true, root = pwd())

This function builds a local website out of the Obsidian markdown files. The function assumes the following file structure:
- `root`
    - `src/`
        - `index.md`
        - `pages/`

A temporary directory `tmp/` and temporary file `_tmp_index.md` will be created inside `src/`.
The temporary files replace Obsidian LaTeX blocks with Documenter math blocks.
The website will then be built in the `"\$root/build/"` directory.
"""
function obsidian_makedocs(;
    root = pwd(),
    sitename = splitdir(root)[2],
)
    _root = root
    root = joinpath(_root, "src")
    isdir(root) || throw("The root folder $root does not exist. Please set the root folder using the `root` keyword argument.")
    pages = joinpath(root, "pages")
    tmp = joinpath(root, "tmp")
    isdir(tmp) && rm(tmp, recursive = true, force = true)
    mkdir(tmp)
    for fn in readdir(pages; join=false)
        news = String(read(joinpath(pages, fn)))
        s = ""
        while s != news
            s = news
            regex = r"((.|\n)*)\$\$((.|\n)+)\$\$((.|\n)*)"
            news = replace(s, regex => s"\1 \n ```math \n \3 \n``` \n \5")
        end
        write(joinpath(tmp, fn), news)
    end
    mv(joinpath(root, "index.md"), joinpath(root, "_tmp_index.md"))
    s = String(read(joinpath(root, "_tmp_index.md")))
    news = replace(s, r"\((.*)pages/(.*)\)" => s"(\1tmp/\2)")
    mainpage = joinpath(root, "index.md")
    write(mainpage, news)
    isdir(joinpath(_root, "build")) && rm(joinpath(_root, "build"), recursive = true)
    Documenter.makedocs(
        sitename = sitename,
        pages = Any["Home" => "index.md"],
        format = Documenter.HTML(prettyurls = false),
    )
    rm(joinpath(root, "index.md"))
    mv(joinpath(root, "_tmp_index.md"), joinpath(root, "index.md"))
    rm(joinpath(_root, "build", "_tmp_index.html"))
    rm(tmp, recursive = true)
    return nothing
end

end
