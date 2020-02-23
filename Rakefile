# frozen_string_literal: true

# original: https://gist.github.com/pocke/a3faa4b87416c3d899e626f9197f2174

namespace :steep do
  task :strip, [:sig_file] => :environment do
    require 'ruby/signature'

    # dedupe classes
    sig_path = Pathname(sig_file)
    decls = Ruby::Signature::Parser.parse_signature(sig_path)
    decl_map = {}
    decls.each do |decl|
      if d = decl_map[decl.name]
        # TODO: Is it right for decl is not a class / module?
        c = Ruby::Signature::AST::Declarations::Class
        m = Ruby::Signature::AST::Declarations::Module
        next unless d.is_a?(c) || d.is_a?(m)
        next unless decl.is_a?(c) || decl.is_a?(m)

        d.members.concat decl.members
        if d.is_a?(c) && decl.is_a?(c)
          decl_map[decl.name] = c.new(name: d.name, type_params: d.type_params, super_class: d.super_class || decl.super_class, members: d.members, annotations: d.annotations, location: d.location, comment: d.comment)
        end
      else
        decl_map[decl.name] = decl
      end
    end
    sig_path.open('w') do |f|
      Ruby::Signature::Writer.new(out: f).write(decl_map.values)
    end
  end
end
