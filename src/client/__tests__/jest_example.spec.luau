--!strict
-- jest_example.spec.luau

describe("jest_example", function()
    it("creates a table with React.createElement", function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local React = require(ReplicatedStorage.Packages.React)

        local testValue = Vector3.new(1,2,3)

        local elem = React.createElement("Part", {
            Position=testValue,
        })

        expect(elem.type).to_equal("Part")
        -- expect(elem['$$typeof']).to_equal(60103) -- This is a React internal detail, might change
        expect(elem.props.Position).to_equal(testValue)
    end)
end)