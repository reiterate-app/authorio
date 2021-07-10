module ActionDispatch::Routing
	class Mapper

		# Provide a custom mounting command, just so we can track our own mount point
		def authorio_routes
			mount Authorio::Engine, at: Authorio.configuration.mount_point
		end
	end
end
